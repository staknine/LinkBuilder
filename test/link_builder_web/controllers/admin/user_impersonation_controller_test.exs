defmodule LinkBuilderWeb.Admin.UserImpersonationControllerTest do
  use LinkBuilderWeb.ConnCase, async: true

  import LinkBuilder.AccountsFixtures

  setup :register_and_log_in_admin

  describe "user impersonation" do
    test "sets current_user and redirects", %{conn: conn} do
      account = account_fixture()
      user = user_fixture(account)

      conn =
        post(conn, Routes.admin_user_impersonation_path(conn, :create, account.id, user.id), %{})

      assert redirected_to(conn) == Routes.app_home_path(conn, :index)

      conn = get(conn,  Routes.admin_dashboard_index_path(conn, :index))
      assert html_response(conn, 200) =~ "Impersonating"
    end
  end
end
