defmodule LinkBuilderWeb.App.TeamLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index as not signed in" do
    test "redirects to sign in", %{conn: conn} do
      assert {:error, {:redirect, %{to: path}}} = live(conn, Routes.app_team_index_path(conn, :index))
      assert path =~ "/sign_in"
    end
  end

  describe "Index" do
    setup [:register_and_log_in_user]

    test "display team page", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.app_team_index_path(conn, :index))

      assert html =~ "Team"
    end
  end
end
