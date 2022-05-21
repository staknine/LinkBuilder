defmodule LinkBuilderWeb.PageControllerTest do
  use LinkBuilderWeb.ConnCase, async: true

  describe "privacy" do
    test "renders page", %{conn: conn} do
      conn = get(conn, "/privacy")
      response = html_response(conn, 200)
      assert response =~ "Privacy"
    end
  end

  describe "terms" do
    test "renders page", %{conn: conn} do
      conn = get(conn, "/terms-and-conditions")
      response = html_response(conn, 200)
      assert response =~ "Terms and Conditions"
    end
  end
end
