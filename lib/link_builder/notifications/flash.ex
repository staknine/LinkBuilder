defmodule LinkBuilder.InAppNotifications.Flash do
  use LinkBuilder.Schema

  embedded_schema do
    field :type, :string, default: "info"
    field :title, :string
    field :body, :string
    field :closable, :boolean, default: true
  end

  # def notify(body) do
  #   Phoenix.PubSub.broadcast(LinkBuilder.PubSub, "flash_notification", {:notify, body})
  # end
  #
  # def subscribe do
  #   Phoenix.PubSub.subscribe(LinkBuilder.PubSub, "flash_notification")
  # end
end
