defmodule LinkBuilder.NotificationsTest do
  use LinkBuilder.DataCase, async: true

  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Notifications

  test "signup" do
    user = user_fixture()

    assert Notifications.signup(user) == :ok

    assert [%LinkBuilder.InAppNotifications.Notification{}] =
             LinkBuilder.InAppNotifications.list_notifications(user)
  end
end
