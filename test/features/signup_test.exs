defmodule LinkBuilder.Features.SignupTest do
  use ExUnit.Case
  use Wallaby.Feature

  import Wallaby.Query
  alias LinkBuilder.Accounts
  alias LinkBuilder.Accounts.User

  @sign_up_link css("header a[href='/sign_up']")
  @name_field text_field("Name")
  @email_field text_field("Email")
  @password_field css("#account_users_0_password")
  @password_confirmation_field css("#account_users_0_password_confirmation")

  feature "users can create an account", %{session: session} do
    session =
      session
      |> visit("/")
      |> assert_text("SAAS Starter Kit")
      |> click(@sign_up_link)
      |> fill_in(@name_field, with: "James Bond")
      |> fill_in(@email_field, with: "jbond@example.com")
      |> fill_in(@password_field, with: "supersecret123")
      |> fill_in(@password_confirmation_field, with: "supersecret123")
      |> click(button("Register"))
      |> assert_has(css(".alert-info label", text: "Account created"))

    assert current_url(session) =~ "/app"
    assert %User{} = Accounts.get_user_by_email_and_password("jbond@example.com", "supersecret123")
  end
end
