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
      |> visit("/reset_password")
      |> assert_text("Forgot your password?")
      |> fill_in(@email_field, with: user.email)
      |> click(button("Send password reset instructions"))
      |> assert_has(
        css(".alert-info label",
          text:
            "If your email is in our system, you will receive instructions to reset your password shortly."
        )
      )

    assert current_url(session) =~ "/"
  end
end
