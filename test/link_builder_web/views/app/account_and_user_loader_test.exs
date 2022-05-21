defmodule LinkBuilderWeb.Views.App.AccountAndUserLoaderTest do
  use LinkBuilderWeb.ConnCase, async: true

  alias LinkBuilderWeb.App.AccountAndUserLoader

  import LinkBuilder.AccountsFixtures

  setup do
    user = user_with_account_fixture()
    %{account: user.account, user: user}
  end

  describe "account_and_user_from_session" do
    test "account_and_user_from_session/1 when account_id and user_id are nil" do
      assert AccountAndUserLoader.account_and_user_from_session(%{
               "account_id" => nil,
               "user_id" => nil
             }) == %{account: nil, user: nil}
    end

    test "account_and_user_from_session/1 when account_id and user_id are present", %{
      account: account,
      user: user
    } do
      assert %{account: ^account, user: %{id: user_id}} =
               AccountAndUserLoader.account_and_user_from_session(%{
                 "account_id" => account.id,
                 "user_id" => user.id
               })
      assert user_id == user.id
    end
  end
end
