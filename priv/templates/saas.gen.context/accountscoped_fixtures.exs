defmodule <%= inspect context.module %>Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `<%= schema.singular %>` context.
  """

  import <%= inspect context.base_module %>.AccountsFixtures

  alias <%= inspect context.module %>
  alias <%= inspect context.base_module %>.Accounts.Account

  @valid_<%= schema.singular %>_attrs <%= inspect schema.params.create %>

  def <%= schema.singular %>_fixture(), do: <%= schema.singular %>_fixture(%{})
  def <%= schema.singular %>_fixture(%Account{} = account), do: <%= schema.singular %>_fixture(account, %{})

  def <%= schema.singular %>_fixture(attrs) do
    account = account_fixture()
    <%= schema.singular %>_fixture(account, attrs)
  end

  def <%= schema.singular %>_fixture(%Account{} = account, attrs) do
    attrs =
      Enum.into(attrs, @valid_<%= schema.singular %>_attrs)

    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(account, attrs)

    <%= inspect context.alias %>.get_<%= schema.singular %>!(account, <%= schema.singular %>.id)
  end
end
