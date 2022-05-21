defmodule LinkBuilderWeb.Admin.ProductLive.Index do
  use LinkBuilderWeb, :live_view_admin
  use Saas.DataTable

  alias LinkBuilder.Billing
  alias LinkBuilder.Billing.Product

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(get_products_assigns(params))
      |> assign(:stripe_enabled, Billing.stripe_enabled?)

    {:ok, socket, temporary_assigns: [products: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    params = set_active_as_default(params) # Filter out archived products

    {
      :noreply,
      socket
      |> assign(:params, params)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Billing.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
    |> assign(get_products_assigns(params))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Billing.get_product!(id)
    {:ok, product} = Billing.update_product(product, %{active: !product.active})
    {:noreply, update(socket, :products, fn products -> [product | products] end)}
  end

  defp get_products_assigns(params) do
    case Billing.paginate_products(params) do
      {:ok, assigns} -> assigns
      _ -> %{}
    end
  end

  defp set_active_as_default(params) do
    plan_params =
      params
      |> Map.get("product", %{})
      |> Map.put_new("active_equals", "true")

    params
    |> Map.merge(%{"product" => plan_params})
    |> Map.put_new("filters", [])
  end
end
