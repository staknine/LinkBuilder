defmodule LinkBuilderWeb.App.Notifications.IndicatorLiveTest do
  use LinkBuilderWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias LinkBuilderWeb.App.Notifications.IndicatorLive
  alias LinkBuilder.InAppNotifications

  describe "logged in" do
    setup [:register_and_log_in_user]

    test "disconnected and connected render", %{conn: conn} do
      {:ok, view, disconnected_html} = live_isolated(conn, IndicatorLive)
      assert disconnected_html =~ "@click.stop=\"sideBarEnd = !sideBarEnd\""
      assert render(view) =~ "@click.stop=\"sideBarEnd = !sideBarEnd\""
      refute render(view) =~ "rounded-full animate-ping"
    end

    test "with an unread notification", %{conn: conn, user: user} do
      InAppNotifications.create_notification(user, %{type: "info", title: "My notification title", body: "My notification body"})
      {:ok, view, _html} = live_isolated(conn, IndicatorLive)
      assert render(view) =~ "rounded-full animate-ping"
    end
  end
end
