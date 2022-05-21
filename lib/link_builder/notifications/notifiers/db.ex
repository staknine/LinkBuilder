defmodule LinkBuilder.Notifications.Notifiers.Db do
  defstruct [:user, :message]

  defimpl Saas.Notifiers do
    alias LinkBuilder.InAppNotifications

    def send(%{user: user, message: message}) do
      if message.type in ~w(all db) do
        attrs = Map.take(message, [:title, :body, :type])
        InAppNotifications.create_notification(user, attrs)
      end
    end
  end
end
