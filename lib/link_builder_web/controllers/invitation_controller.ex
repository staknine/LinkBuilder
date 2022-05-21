defmodule LinkBuilderWeb.InvitationController do
  use LinkBuilderWeb, :controller

  alias LinkBuilder.Accounts
  alias LinkBuilder.Accounts.User
  alias LinkBuilderWeb.UserAuth

  plug :require_valid_token when action in [:new, :create]

  defp require_valid_token(conn, _opts) do
    with %{"token" => token} <- conn.params,
         {:ok, account_id} <- Phoenix.Token.verify(LinkBuilderWeb.Endpoint, "invite_member", token, max_age: 86400) do

      account = Accounts.get_account!(account_id)

      conn
      |> assign(:account, account)
      |> assign(:token, token)
    else
      _ ->
        conn
        |> put_flash(:error, "The link you clicked is no longer valid")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt()
    end
  end

  def new(conn, %{"token" => token}) do
    changeset = Accounts.change_user_registration(%User{})

    render(conn, "new.html", changeset: changeset, token: token)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(conn.assigns.account, user_params) do
      {:ok, user} ->
        conn
        |> UserAuth.log_in_user_without_redirect(user)
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.app_home_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
