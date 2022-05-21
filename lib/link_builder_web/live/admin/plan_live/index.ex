defmodule LinkBuilderWeb.Admin.PlanLive.Index do
  use LinkBuilderWeb, :live_view_admin
  use Saas.DataTable

  alias LinkBuilder.Billing
  alias LinkBuilder.Billing.Plan

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(get_plans_assigns(params))
      |> assign(:products, Billing.list_products())
      |> assign(:stripe_enabled, Billing.stripe_enabled?)

    {:ok, socket, temporary_assigns: [plans: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    params = set_active_as_default(params) # Filter out archived plans

    {
      :noreply,
      socket
      |> assign(:params, params)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Plan")
    |> assign(:plan, Billing.get_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Plan")
    |> assign(:plan, %Plan{product: nil})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Plans")
    |> assign(:plan, nil)
    |> assign(get_plans_assigns(params))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    plan = Billing.get_plan!(id) |> LinkBuilder.Repo.preload(:product)
    {:ok, plan} = Billing.update_plan(plan, %{active: !plan.active})

    {:noreply, update(socket, :plans, fn plans -> [plan | plans] end)}
  end

  defp get_plans_assigns(params) do
    case Billing.paginate_plans(params) do
      {:ok, assigns} -> assigns
      _ -> %{}
    end
  end

  defp set_active_as_default(params) do
    plan_params =
      params
      |> Map.get("plan", %{})
      |> Map.put_new("active_equals", "true")

    params
    |> Map.merge(%{"plan" => plan_params})
    |> Map.put_new("filters", [])
  end
end
