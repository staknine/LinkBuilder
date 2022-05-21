defmodule LinkBuilder.InAppNotifications.Notification do
  use LinkBuilder.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :read_at, :naive_datetime
    field :discarded_at, :naive_datetime
    field :type, :string, default: ""
    field :title, :string
    field :body, :string

    belongs_to :user, LinkBuilder.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :title, :body, :read_at, :discarded_at])
    |> validate_required([:title])
  end
end
