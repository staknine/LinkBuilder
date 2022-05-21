defmodule LinkBuilderWeb.App.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  """

  import Phoenix.LiveView
  alias LinkBuilder.Accounts

  def on_mount(:default, _params, %{"user_token" => token}, socket) when is_binary(token) do
    case Accounts.get_user_by_session_token(token) do
      %{} = user ->
        user = Accounts.with_account(user)
        {
          :cont,
          socket
          |> assign(:account, user.account)
          |> assign(:user, user)
        }
      _ ->
        {:halt, redirect(socket, to: "/sign_in")}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, redirect(socket, to: "/sign_in")}
  end
end
