defmodule LinkBuilder.InAppNotifications do
  @moduledoc """
  The NotificationHandler context.
  """

  import Ecto.Query, warn: false
  alias LinkBuilder.Repo

  alias LinkBuilder.InAppNotifications.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications(user)
      [%Notification{}, ...]

  """
  def list_notifications(user) do
    from(
      n in Notification,
      where: n.user_id == ^user.id,
      where: is_nil(n.discarded_at),
      order_by: [desc: :inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of notifications for menu.

  ## Examples

      iex> list_notifications_for_menu(user)
      [%Notification{}, ...]

  """
  def list_notifications_for_menu(user) do
    from(
      n in Notification,
      where: n.user_id == ^user.id,
      where: is_nil(n.read_at),
      where: is_nil(n.discarded_at),
      order_by: [desc: :inserted_at],
      limit: 10
    )
    |> Repo.all()
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(user, id), do: Repo.get_by!(Notification, user_id: user.id, id: id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:notifications)
    |> Notification.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  defp notify_subscribers({:ok, notification} = result) do
    Phoenix.PubSub.broadcast(LinkBuilder.PubSub, "notification:#{notification.user_id}", %{notification: notification})
    result
  end

  defp notify_subscribers(result), do: result

  def subscribe_on_notification_created(user_id) do
    Phoenix.PubSub.subscribe(LinkBuilder.PubSub, "notification:#{user_id}")
  end
end
