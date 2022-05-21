defmodule LinkBuilderWeb.Admin.UserLive.NotificationComponent do
  use LinkBuilderWeb, :live_component
  use Saas.NotificationCenter

  @impl true
  def update(assigns, socket) do
    message = %Message{}
    changeset = change_message(message)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:message, message)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      socket.assigns.message
      |> change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    user = socket.assigns.user

    changeset =
      socket.assigns.message
      |> change_message(message_params)

    case changeset do
      %Ecto.Changeset{valid?: true} = changeset ->
        message = Ecto.Changeset.apply_changes(changeset)
        LinkBuilder.Notifications.general(user, message)

        {:noreply,
         socket
         |> put_flash(:info, "Notification created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      changeset ->
        error_changeset = Map.put(changeset, :action, :validate)
        {:noreply, assign(socket, changeset: error_changeset)}
    end
  end
end
