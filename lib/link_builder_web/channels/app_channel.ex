defmodule LinkBuilderWeb.AppChannel do
  use LinkBuilderWeb, :channel

  @impl true
  def join("app:" <> token, _payload, socket) do
    if authorized?(socket) do
      {:ok, assign(socket, :channel_name, "app:#{token}")}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Can be triggered by from the frontend js by:
  # channel.push('flash', message)
  @impl true
  def handle_in("flash", payload, socket) do
    Saas.AppChannelHelper.broadcast_to_user_channel(socket.assigns.channel_name, payload)

    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp authorized?(socket) do
    case socket.assigns[:user_id] do
      nil -> false
      "" <> _user_id -> true
    end
  end
end
