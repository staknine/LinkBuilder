defmodule LinkBuilderWeb.Admin.PlanLive.FormComponent do
  use LinkBuilderWeb, :live_component

  alias LinkBuilder.Billing

  @impl true
  def update(%{plan: plan} = assigns, socket) do
    changeset = Billing.change_plan(plan)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"plan" => plan_params}, socket) do
    changeset =
      socket.assigns.plan
      |> Billing.change_plan(plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"plan" => plan_params}, socket) do
    save_plan(socket, socket.assigns.action, plan_params)
  end

  defp save_plan(socket, :edit, plan_params) do
    case Billing.update_plan(socket.assigns.plan, plan_params) do
      {:ok, _plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plan updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_plan(socket, :new, plan_params) do
    product = Enum.find(socket.assigns.products, &(&1.id == plan_params["product"]))

    case Billing.create_plan(product, plan_params) do
      {:ok, _plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plan created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect changeset
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
