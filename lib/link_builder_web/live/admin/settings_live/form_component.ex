defmodule LinkBuilderWeb.Admin.SettingLive.FormComponent do
  use LinkBuilderWeb, :live_component

  alias LinkBuilder.Admins

  @impl true
  def update(%{admin: admin} = assigns, socket) do
    changeset = Admins.change_admin(admin)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"admin" => admin_params}, socket) do
    changeset =
      socket.assigns.admin
      |> Admins.change_admin(admin_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"admin" => admin_params}, socket) do
    case Admins.update_admin(socket.assigns.admin, admin_params) do
      {:ok, _admin} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "User updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
