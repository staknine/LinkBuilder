defmodule LinkBuilderWeb.AccountRegistrationControllerTest do
  use LinkBuilderWeb.ConnCase, async: true

  import LinkBuilder.AccountsFixtures

  describe "new account" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.account_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Sign up to our product today</h5>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</button>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_with_account_fixture())
        |> get(Routes.account_registration_path(conn, :new))

      assert redirected_to(conn) == "/app"
    end
  end

  describe "create account" do
    test "creates account and logs the user in", %{conn: conn} do
      conn =
        post(conn, Routes.account_registration_path(conn, :create), %{
          "account" => %{
            "name" => "some company name",
            "users" => [%{email: unique_user_email(), password: valid_user_password(), password_confirmation: valid_user_password()}]
          }
        })

      assert redirected_to(conn) =~ "/app"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ "Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.account_registration_path(conn, :create), %{
          "account" => %{
            "name" => nil,
            "users" => [%{"email" => "with spaces", "password" => "short"}]
          }
        })

      response = html_response(conn, 200)
      assert response =~ "Sign up to our product today</h5>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character(s)"
    end
  end
end
