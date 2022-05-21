defmodule LinkBuilder.Billing.SynchronizePlans do
  alias LinkBuilder.Billing.Products
  alias LinkBuilder.Billing.Plans

  @stripe_service Application.get_env(:link_builder, :stripe_service)

  defp get_all_plans_from_stripe do
    {:ok, %{data: plans}} = @stripe_service.Plan.list(%{})
    plans
  end

  def run do
    # First, we gather our existing products
    plans_by_stripe_id =
      Plans.list_plans()
      |> Enum.group_by(& &1.stripe_id)

    existing_stripe_ids =
      get_all_plans_from_stripe()
      |> Enum.map(fn stripe_plan ->
        attrs = stripe_plan_attrs(stripe_plan)
        billing_product = Products.get_product_by_stripe_id!(stripe_plan.product)

        case Map.get(plans_by_stripe_id, stripe_plan.id) do
          nil ->
            Plans.create_plan(billing_product, attrs)

          [billing_plan] ->
            Plans.update_plan(billing_plan, attrs)
        end

        stripe_plan.id
      end)

    plans_by_stripe_id
    |> Enum.reject(fn {stripe_id, _billing_plan} ->
      Enum.member?(existing_stripe_ids, stripe_id)
    end)
    |> Enum.each(fn {_stripe_id, [billing_plan]} ->
      Plans.delete_plan(billing_plan)
    end)
  end

  defp stripe_plan_attrs(stripe_plan) do
    name = stripe_plan.name || stripe_plan.nickname || stripe_plan.interval
    id = stripe_plan.id

    stripe_plan
    |> Map.from_struct()
    |> Map.put(:name, name)
    |> Map.put(:stripe_id, id)
  end
end
