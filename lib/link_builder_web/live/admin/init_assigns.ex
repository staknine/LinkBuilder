defmodule LinkBuilderWeb.Admin.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  import Phoenix.LiveView
  alias LinkBuilder.Accounts
  alias LinkBuilderWeb.Router.Helpers, as: Routes

  def on_mount(:require_account, _params, %{"admin_account_id" => account_id}, socket) do
    account = Accounts.get_account!(account_id)
    {:cont, assign(socket, :account, account)}
  end

  def on_mount(:require_account, _params, _session, socket) do
    {:halt,
      socket
      |> put_flash(:error, "You need to switch to an account first")
      |> push_redirect(to: Routes.admin_account_index_path(socket, :index))}
  end
end
