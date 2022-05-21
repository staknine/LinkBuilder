defmodule LinkBuilder.Accounts.Guardian do
  use Guardian, otp_app: :link_builder

  alias LinkBuilder.Accounts

  @doc """
  Used when encoding a JWT for the GraphQL authentication. Both user_id
  and account_id are encoded.
  """
  def subject_for_token(user, _claims) do
    {:ok, %{user_id: to_string(user.id), account_id: to_string(user.account_id)}}
  end

  @doc """
  Used when decoding a JWT for the GraphQL authentication.
  """
  def resource_from_claims(%{"sub" => %{"user_id" => user_id, "account_id" => account_id}}) do
    account = Accounts.get_account!(account_id)
    user = Accounts.get_user!(account, user_id)

    {:ok, %{account: account, user: user}}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
