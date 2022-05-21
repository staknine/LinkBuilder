defmodule LinkBuilder.Teams do
  @moduledoc """
  Module is responsible for team related functions.
  """

  alias LinkBuilder.Emails
  alias LinkBuilder.Mailer
  alias LinkBuilderWeb.Router.Helpers, as: Routes

  @doc """
  Invite a user to specific account. Sends an email with a magic link to the
  provided email. The user that clicks on the link will be presented with a
  signup form in LinkBuilderWeb.InvitationController
  """
  def invite_member(%{account_id: account_id, email: email}) do
    token = Phoenix.Token.sign(LinkBuilderWeb.Endpoint, "invite_member", account_id)
    url = Routes.invitation_url(LinkBuilderWeb.Endpoint, :new, token)

    Emails.invite_user_email(%{email: email, url: url})
    |> Mailer.deliver_later()
  end
end
