defmodule LinkBuilder.InAppNotificationsTest do
  use LinkBuilder.DataCase

  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.InAppNotifications
  alias LinkBuilder.InAppNotifications.Notification

  describe "notifications" do
    @valid_attrs %{read_at: ~N[2010-04-17 14:00:00], title: "some title"}
    @update_attrs %{read_at: ~N[2011-05-18 15:01:01], title: "some updated title"}
    @invalid_attrs %{read_at: nil, title: nil}

    def notification_fixture(), do: notification_fixture(user_fixture(), %{})
    def notification_fixture(%LinkBuilder.Accounts.User{} = user), do: notification_fixture(user, %{})
    def notification_fixture(%{} = attrs), do: notification_fixture(user_fixture(), attrs)
    def notification_fixture(user, attrs) do
      attrs = Enum.into(attrs, @valid_attrs)
      {:ok, notification} = InAppNotifications.create_notification(user, attrs)

      notification
    end

    test "list_notifications/0 returns all notifications" do
      user = user_fixture()
      notification = notification_fixture(user)
      assert InAppNotifications.list_notifications(user) == [notification]
    end

    test "list_notifications/0 excludes discarded notifications" do
      user = user_fixture()
      _notification = notification_fixture(user, %{discarded_at: ~N[2020-01-01 00:00:00]})
      assert InAppNotifications.list_notifications(user) == []
    end

    test "get_notification!/1 returns the notification with given id" do
      user = user_fixture()
      notification = notification_fixture(user)
      assert InAppNotifications.get_notification!(user, notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      user = user_fixture()
      assert {:ok, %Notification{} = notification} = InAppNotifications.create_notification(user, @valid_attrs)
      assert notification.read_at == ~N[2010-04-17 14:00:00]
      assert notification.title == "some title"
      assert notification.user_id == user.id
    end

    test "create_notification/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = InAppNotifications.create_notification(user, @invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{} = notification} = InAppNotifications.update_notification(notification, @update_attrs)
      assert notification.read_at == ~N[2011-05-18 15:01:01]
      assert notification.title == "some updated title"
    end

    test "update_notification/2 with invalid data returns error changeset" do
      user = user_fixture()
      notification = notification_fixture(user)
      assert {:error, %Ecto.Changeset{}} = InAppNotifications.update_notification(notification, @invalid_attrs)
      assert notification == InAppNotifications.get_notification!(user, notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      user = user_fixture()
      notification = notification_fixture(user)
      assert {:ok, %Notification{}} = InAppNotifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> InAppNotifications.get_notification!(user, notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = InAppNotifications.change_notification(notification)
    end
  end
end
