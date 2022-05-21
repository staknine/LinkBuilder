defmodule LinkBuilderWeb.Admin.PlanLive.Show do
  use LinkBuilderWeb, :live_view_admin

  alias LinkBuilder.Billing

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:plan, get_plan(id))}
  end

  defp page_title(:show), do: "Show Plan"
  defp page_title(:edit), do: "Edit Plan"

  defp get_plan(id) do
    id
    |> Billing.get_plan!()
    |> Billing.with_product()
  end
end
