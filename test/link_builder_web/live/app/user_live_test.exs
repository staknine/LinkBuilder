defmodule LinkBuilderWeb.App.UserLiveTest do
  use LinkBuilderWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import LinkBuilder.AccountsFixtures

  describe "Edit" do
    setup :register_and_log_in_user

    test "displays the user settings form", %{conn: conn, user: user} do
      {:ok, _edit_live, html} = live(conn, "/app/settings")
      assert html =~ "Change e-mail"
      assert html =~ user.email
    end

    test "it can successfully update the email", %{conn: conn} do
      {:ok, edit_live, _html} = live(conn, "/app/settings")

      new_email = unique_user_email()

      {:ok, _, html} =
        edit_live
        |> form("#update-email-form",
          user: %{email: new_email},
          current_password: valid_user_password()
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.app_user_edit_path(conn, :edit))

      assert html =~ "A link to confirm your email change has been sent to the new address."
    end

    test "it can successfully update the password and redirects to sign_in", %{conn: conn} do
      {:ok, edit_live, _html} = live(conn, "/app/settings")

      new_password = "updated password"

      assert {_, {:live_redirect, %{to: "/sign_in"}}} =
        edit_live
        |> form("#update-password-form",
          user: %{
            password: new_password,
            password_confirmation: new_password,
            current_password: valid_user_password()
          }
        )
        |> render_submit()
    end
  end
end
