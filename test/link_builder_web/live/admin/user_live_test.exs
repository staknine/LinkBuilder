defmodule LinkBuilderWeb.Admin.UserLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest
  import LinkBuilder.AccountsFixtures

  @notify_attrs %{title: "a new notification", body: "some content", type: "all"}
  @invalid_attrs %{title: nil, body: nil, type: "all"}

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_user, :switch_account]

    test "lists all users", %{conn: conn, user: user} do
      {:ok, _index_live, html} = live(conn, Routes.admin_user_index_path(conn, :index))

      assert html =~ "Listing Users"
      assert html =~ user.email
    end

    test "saves new user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_user_index_path(conn, :index))

      assert index_live |> element("a[href=\"/admin/users/new\"]") |> render_click() =~
               "New User"

      assert_patch(index_live, Routes.admin_user_index_path(conn, :new))

      assert index_live
             |> form("#user-form", user: %{email: nil})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: %{email: "valid-email@example.com"})
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_user_index_path(conn, :index))

      assert html =~ "User created successfully"
      assert html =~ "valid-email@example.com"
    end

    test "sends a message to a user in listing", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, Routes.admin_user_index_path(conn, :index))

      assert index_live |> element("#user-#{user.id} a", "Notify") |> render_click() =~
               "Notify User"

      assert_patch(index_live, Routes.admin_user_index_path(conn, :notify, user))

      assert index_live
             |> form("#notification-form", message: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#notification-form", message: @notify_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_user_index_path(conn, :index))

      assert html =~ "Notification created successfully"
    end

    test "deletes user in listing", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, Routes.admin_user_index_path(conn, :index))

      assert index_live |> element("#user-#{user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user-#{user.id}")
    end
  end

  describe "Show" do
    setup [:create_user, :switch_account]

    test "displays user", %{conn: conn, user: user} do
      {:ok, _show_live, html} = live(conn, Routes.admin_user_show_path(conn, :show, user))

      assert html =~ "Show User"
      assert html =~ user.email
    end
  end
end
