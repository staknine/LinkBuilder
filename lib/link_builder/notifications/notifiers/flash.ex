defmodule LinkBuilder.Notifications.Notifiers.Flash do
  defstruct [:user, :message]

  defimpl Saas.Notifiers do
    def send(%{user: user, message: message}) do
      if message.type in ~w(all flash) do
        payload = %{"body" => "#{message.title} #{message.body}", "type" => "info"}

        Saas.AppChannelHelper.broadcast_to_user_channel("app:" <> user.channel_name, payload)
      end
    end
  end
end
