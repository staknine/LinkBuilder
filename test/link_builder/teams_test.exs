defmodule LinkBuilder.TeamsTest do
  use LinkBuilder.DataCase, async: true

  import Swoosh.TestAssertions
  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Teams

  test "invite_member/1 sends the email with the decodable token" do
    email = "some@email.com"
    account = account_fixture()

    Teams.invite_member(%{account_id: account.id, email: email})

    assert_email_sent subject: "Invited to join"
  end
end
