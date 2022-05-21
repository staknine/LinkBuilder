defmodule LinkBuilderWeb.InvitationControllerTest do
  use LinkBuilderWeb.ConnCase, async: true

  import LinkBuilder.AccountsFixtures

  def valid_token(_) do
    account = account_fixture()

    %{token: Phoenix.Token.sign(LinkBuilderWeb.Endpoint, "invite_member", account.id)}
  end

  describe "new user from invitation with invalid token" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.invitation_path(conn, :new, "invalid"))
      assert redirected_to(conn) == "/"
    end
  end

  describe "new user from invitation with valid token" do
    setup :valid_token

    test "renders form", %{conn: conn, token: token} do
      conn = get(conn, Routes.invitation_path(conn, :new, token))
      response = html_response(conn, 200)
      assert response =~ "Sign up and join the team</h5>"
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

  describe "create invited user" do
    setup :valid_token

    test "creates account and logs the user in", %{conn: conn, token: token} do
      conn =
        post(conn, Routes.invitation_path(conn, :create), %{
          "token" => token,
          "user" => %{
            "email" => unique_user_email(),
            "password" => valid_user_password(),
            "password_confirmation" => valid_user_password()
          }
        })

      assert redirected_to(conn) =~ "/app"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/app")
      response = html_response(conn, 200)
      assert response =~ "Settings</a>"
      assert response =~ "Sign Out</a>"
    end

    test "render errors for invalid data", %{conn: conn, token: token} do
      conn =
        post(conn, Routes.invitation_path(conn, :create), %{
          "token" => token,
          "user" => %{
            "email" => "with spaces",
            "password" => "short"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "Sign up and join the team</h5>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
