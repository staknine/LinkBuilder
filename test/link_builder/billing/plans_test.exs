defmodule LinkBuilder.Billing.PlansTest do
  use LinkBuilder.DataCase, async: true

  import LinkBuilder.BillingFixtures

  alias LinkBuilder.Billing.Plans
  alias LinkBuilder.Billing.Plan
  alias LinkBuilder.Billing.Product

  describe "plans" do
    test "paginate_plans/1 returns paginated list of plans" do
      for _ <- 1..20 do
        product = product_fixture()
        plan_fixture(product)
      end

      {:ok, %{plans: plans} = page} = Plans.paginate_plans(%{})

      assert length(plans) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_plans/0 returns all plans" do
      plan = plan_fixture()
      assert Plans.list_plans() == [plan]
    end

    test "list_plans_for_subscription_page/0 returns all plans" do
      plan_fixture()
      assert [%{amount: 42, name: "Premium Plan", period: "some name"}] = Plans.list_plans_for_subscription_page()
    end

    test "get_plan!/1 returns the plan with given id" do
      plan = plan_fixture()
      assert Plans.get_plan!(plan.id) == plan
    end

    test "get_plan_by_stripe_id!/1 returns the plan with given stripe_id" do
      plan = plan_fixture()
      assert Plans.get_plan_by_stripe_id!(plan.stripe_id) == plan
    end

    test "with_product/1 loads the product for a specific plan" do
      product = product_fixture()
      plan = plan_fixture(product)
      assert %Plan{product: %Product{}} = Plans.with_product(plan)
    end

    test "with_product/1 loads the product for a list of plans" do
      product = product_fixture()
      plan = plan_fixture(product)
      assert [%Plan{product: %Product{}}] = Plans.with_product([plan])
    end

    test "create_plan/1 with valid data creates a plan" do
      product = product_fixture()
      assert {:ok, %Plan{} = plan} = Plans.create_plan(product, %{amount: 42, name: "some name"})
      assert plan.amount == 42
      assert "price_" <> _ = plan.stripe_id
      assert plan.name == "some name"
    end

    test "create_plan/1 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Plans.create_plan(product, %{amount: nil, name: nil})
    end

    test "update_plan/2 with valid data updates the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{} = plan} = Plans.update_plan(plan, %{amount: 43, name: "some updated name"})
      assert plan.amount == 43
      assert plan.name == "some updated name"
    end

    test "update_plan/2 with invalid data returns error changeset" do
      plan = plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Plans.update_plan(plan, %{amount: nil, name: nil})
      assert plan == Plans.get_plan!(plan.id)
    end

    test "delete_plan/1 deletes the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{}} = Plans.delete_plan(plan)
      assert_raise Ecto.NoResultsError, fn -> Plans.get_plan!(plan.id) end
    end

    test "change_plan/1 returns a plan changeset" do
      plan = plan_fixture()
      assert %Ecto.Changeset{} = Plans.change_plan(plan)
    end
  end
end
