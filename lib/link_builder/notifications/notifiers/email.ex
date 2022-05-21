defmodule LinkBuilder.Notifications.Notifiers.Email do
  defstruct [:user, :message]

  defimpl Saas.Notifiers do
    def send(%{user: user, message: message}) do
      if message.type in ~w(all email) do
        LinkBuilder.Emails.notification_email(user, message)
        |> LinkBuilder.Mailer.deliver_later()
      end
    end
  end
end
