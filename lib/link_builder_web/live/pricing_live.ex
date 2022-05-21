defmodule LinkBuilderWeb.PricingLive do
  use LinkBuilderWeb, :live_view

  alias LinkBuilder.Billing
  alias LinkBuilderWeb.PricingPage.ProductComponent

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(:products, get_products())
      |> assign(:price_interval, "month")
    }
  end

  @impl true
  def handle_event("set-interval", %{"interval" => price_interval}, socket) do
    {:noreply, assign(socket, :price_interval, price_interval)}
  end

  def plan_price_for_interval(plans, interval \\ "month") do
    plans
    |> Enum.find(& &1.name == interval)
    |> (fn(plan) -> plan || %{} end).()
    |> Map.get(:amount)
  end

  defp get_products() do
    Billing.list_products()
    |> Billing.with_plans()
    |> Enum.filter(&(&1.plans != []))
    |> Enum.sort_by(&cheapest_plan_price/1)
  end

  defp cheapest_plan_price(product) do
    product.plans
    |> Enum.map(& &1.amount)
    |> Enum.min()
  end
end
