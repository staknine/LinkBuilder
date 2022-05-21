defmodule LinkBuilderWeb.App.HomeLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "logged in" do
    setup :register_and_log_in_user

    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/app")
      assert disconnected_html =~ "Build your app here"
      assert render(page_live) =~ "Build your app here"
    end
  end
end
