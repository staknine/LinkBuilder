defmodule <%= inspect context.module %>Test do
  use <%= inspect context.base_module %>.DataCase

  import <%= inspect context.base_module %>.AccountsFixtures

  alias <%= inspect context.module %>

  def setup_account(_) do
    account = account_fixture()
    {:ok, account: account}
  end
end
