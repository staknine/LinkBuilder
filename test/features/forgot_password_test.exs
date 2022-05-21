defmodule LinkBuilder.Features.ForgotPasswordTest do
  use ExUnit.Case
  use Wallaby.Feature

  import Wallaby.Query
  import LinkBuilder.AccountsFixtures

  @email_field text_field("Email")

  feature "a user can recover a password", %{session: session} do
    user = user_fixture()

    session =
      session
      |> visit("/app/reset_password")
      |> assert_text("Forgot your password?")
      |> fill_in(@email_field, with: user.email)
      |> click(button("Send password reset instructions"))
      |> assert_has(css(".alert-info label", text: "an email with reset instructions will be sent to you"))


    assert current_url(session) =~ "/app/session/new"
  end
end
