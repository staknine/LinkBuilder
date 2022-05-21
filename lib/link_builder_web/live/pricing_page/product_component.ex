defmodule LinkBuilderWeb.PricingPage.ProductComponent do
  use LinkBuilderWeb, :live_component

  @impl true
  def update(assigns, socket) do
    amount =
      assigns.product.plans
      |> plan_price_for_interval(assigns.price_interval)
      |> format_price()

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:amount, amount)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <p class="mb-1 text-sm font-semibold tracking-wide uppercase text-primary"><%= @product.name %></p>
      <h1 class="mb-2 text-4xl font-bold leading-tight md:font-extrabold">
        <%= @amount %><span class="text-2xl font-medium"> per <%= @price_interval %> </span>
      </h1>
      <p class="mb-6 text-lg text-neutral">
        One plan for any organization—from startups to Fortune 500s. We offer 50% off of for all
        students and universities. Please get in touch with us and provide proof of your
        status.
      </p>
      <div class="justify-center block md:flex space-x-0 md:space-x-2 space-y-2 md:space-y-0">
        <a href="#" class="w-full btn btn-primary btn-lg md:w-auto">Get Started</a>
      </div>
    </div>
    """
  end

  defp plan_price_for_interval(plans, interval) do
    plans
    |> Enum.find(&(&1.name == interval))
    |> (fn plan -> plan || %{} end).()
    |> Map.get(:amount)
  end

  defp format_price(amount) when is_integer(amount) do
    rounded_amount = round(amount / 100)
    "$#{rounded_amount}"
  end
  defp format_price(_), do: "$ -"
end
