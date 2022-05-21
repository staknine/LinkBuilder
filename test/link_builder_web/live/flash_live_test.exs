defmodule LinkBuilderWeb.FlashLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LinkBuilderWeb.FlashLive

  describe "displays a plain flash message" do
    test "disconnected and connected render", %{conn: conn} do
      {:ok, view, disconnected_html} = live_isolated(conn, FlashLive, session: %{"info" => "A flash message"})
      assert disconnected_html =~ "A flash message"
      assert render(view) =~ "A flash message"
    end
  end

  describe "displays a background sent flash message" do
    test "displayed a received message", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, FlashLive, session: %{})

      send(view.pid, {:notify, %{"body" => "A background message", "type" => "info"}})

      assert render(view) =~ "A background message"
    end

    test "clears a received message when its closed", %{conn: conn} do
      {:ok, view, _html} = live_isolated(conn, FlashLive, session: %{})

      send(view.pid, {:notify, %{"body" => "A background message", "type" => "info"}})

      assert view |> element("button[phx-click=\"clear\"]") |> render_click()
      refute render(view) =~ "A background message"
    end
  end
end
