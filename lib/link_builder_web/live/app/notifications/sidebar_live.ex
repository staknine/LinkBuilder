defmodule LinkBuilderWeb.App.Notifications.SidebarLive do
  use Phoenix.LiveView,
    namespace: LinkBuilderWeb,
    container: {:div, class: ""}

  on_mount LinkBuilderWeb.App.InitAssigns

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.user
    LinkBuilder.InAppNotifications.subscribe_on_notification_created(user.id)

    {
      :ok,
      socket
      |> assign(:notifications, get_notifications(user))
    }
  end

  @impl true
  def handle_event("discard", %{"id" => id}, socket) do
    notifications =
      socket.assigns.notifications
      |> Enum.reject(& &1.id == id)

    LinkBuilder.InAppNotifications.get_notification!(socket.assigns.user, id)
    |> LinkBuilder.InAppNotifications.update_notification(%{discarded_at: NaiveDateTime.utc_now()})

    {:noreply, assign(socket, :notifications, notifications)}
  end

  @impl true
  def handle_info(%{notification: notification}, socket) do
    {:noreply, assign(socket, :notifications, [notification | socket.assigns.notifications])}
  end
  def handle_info(_, socket), do: {:noreply, socket}

  defp get_notifications(nil), do: []

  defp get_notifications(user) do
    LinkBuilder.InAppNotifications.list_notifications_for_menu(user)
  end
end
