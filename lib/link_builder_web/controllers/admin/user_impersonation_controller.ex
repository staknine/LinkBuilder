defmodule LinkBuilderWeb.Admin.UserImpersonationController do
  use LinkBuilderWeb, :controller

  alias LinkBuilder.Accounts

  def create(conn, %{"account_id" => account_id, "id" => id}) do
    account = Accounts.get_account!(account_id)
    user = Accounts.get_user!(account, id)
    token = Accounts.generate_user_session_token(user)

    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
    |> put_flash(:info, "Impersonating user")
    |> redirect(to: Routes.app_home_path(conn, :index))
  end
end
