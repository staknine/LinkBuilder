defmodule LinkBuilderWeb.FlashLive do
  use LinkBuilderWeb, :live_view_no_layout

  alias LinkBuilder.InAppNotifications.Flash

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: setup_subscriptions(session)

    notifications =
      Enum.reduce(~w(error info success), [], fn type, notifications ->
        case Map.get(session, type) do
          "" <> body -> [%Flash{body: body, type: type, id: Ecto.UUID.generate()} | notifications]
          _ -> notifications
        end
      end)

    {:ok,
      socket
      |> assign(:notifications, notifications)
    }
  end

  @impl true
  def handle_info({:notify, %{"body" => body, "type" => type}}, socket) do
    notifications =
      [%Flash{body: body, type: type, id: Ecto.UUID.generate()} | socket.assigns.notifications]
      |> Enum.uniq_by(& &1.body)

    {:noreply, assign(socket, notifications: notifications)}
  end

  @impl true
  def handle_event("clear", %{"id" => id}, socket) do
    notifications =
      socket.assigns.notifications
      |> Enum.reject(& &1.id == id)

    {:noreply, assign(socket, notifications: notifications)}
  end

  defp setup_subscriptions(%{"app_channel" => app_channel}) do
    Saas.AppChannelHelper.subscribe_to_user_channel(app_channel)
  end
  defp setup_subscriptions(_), do: nil
end
