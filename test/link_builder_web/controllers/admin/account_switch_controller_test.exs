defmodule LinkBuilderWeb.Admin.AccountSwitchControllerTest do
  use LinkBuilderWeb.ConnCase, async: true

  import LinkBuilder.AccountsFixtures

  setup :register_and_log_in_admin

  describe "switches account for the admin to view" do
    test "changes admin_account_id and redirects", %{conn: conn} do
      account = account_fixture()

      conn =
        post(conn, Routes.admin_account_switch_path(conn, :create, account.token), %{})

      assert redirected_to(conn) == Routes.admin_dashboard_index_path(conn, :index)

      conn = get(conn,  Routes.admin_dashboard_index_path(conn, :index))
      assert html_response(conn, 200) =~ "Viewing: #{account.name}"
    end
  end
end
