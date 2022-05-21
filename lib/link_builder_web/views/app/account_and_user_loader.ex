defmodule LinkBuilderWeb.App.AccountAndUserLoader do
  alias LinkBuilder.Accounts

  def account_and_user_from_session(%{"current_account_id" => account_id, "current_user_id" => user_id}) do
    account_and_user_from_session(%{"account_id" => account_id, "user_id" => user_id})
  end

  def account_and_user_from_session(%{"account_id" => account_id, "user_id" => user_id}) when is_binary(account_id) do
    account = Accounts.get_account!(account_id)
    user = Accounts.get_user!(account, user_id)

    %{account: account, user: user}
  end

  def account_and_user_from_session(_) do
    %{account: nil, user: nil}
  end
end
