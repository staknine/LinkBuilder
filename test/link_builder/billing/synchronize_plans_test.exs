defmodule LinkBuilder.Billing.SynchronizePlansTest do
  use LinkBuilder.DataCase

  alias LinkBuilder.Billing
  alias LinkBuilder.Billing.Plans
  alias LinkBuilder.Billing.SynchronizePlans

  def create_product(_) do
    {:ok, product} =
      Billing.create_product(%{
        name: "Standard Product",
        stripe_id: "prod_I2TE8siyANz84p"
      })

    %{product: product}
  end

  describe "run" do
    setup [:create_product]

    test "run/0 syncs plans from stripe and creates them in billing_plans" do
      assert Plans.list_plans() == []

      SynchronizePlans.run()
      assert [%LinkBuilder.Billing.Plan{}] = Plans.list_plans()
    end

    test "run/0 deletes plans that exists in local database but does not exists in stripe", %{product: product} do
      {:ok, plan} =
        Plans.create_plan(product, %{
          name: "Dont exists",
          stripe_id: "price_abc123def456",
          amount: 666
        })

      assert Plans.list_plans() == [plan]

      SynchronizePlans.run()
      assert_raise Ecto.NoResultsError, fn -> Plans.get_plan!(plan.id) end
    end
  end
end
