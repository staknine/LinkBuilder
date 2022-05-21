defmodule LinkBuilder.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LinkBuilder.Accounts` context.
  """

  alias LinkBuilder.Accounts.Account
  alias LinkBuilder.Accounts

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def user_fixture(%Account{} = account, attrs) do
    attrs = Enum.into(attrs, %{email: unique_user_email(), password: valid_user_password(), password_confirmation: valid_user_password()})
    {:ok, user} = LinkBuilder.Accounts.register_user(account, attrs)

    user
  end

  def user_fixture(%Account{} = account), do: user_fixture(account, %{})

  def user_fixture(attrs) do
    account = account_fixture()
    user_fixture(account, attrs)
  end

  def user_fixture() do
    account = account_fixture()
    user_fixture(account, %{})
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.text_body, "[TOKEN]")
    token
  end

  def user_with_account_fixture(attrs \\ %{}) do
    account_fixture()
    |> user_fixture(attrs)
    |> LinkBuilder.Repo.preload(:account)
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{name: "some name"})
      |> Accounts.create_account()

    account
  end
end
