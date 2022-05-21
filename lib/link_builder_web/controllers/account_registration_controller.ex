defmodule LinkBuilderWeb.AccountRegistrationController do
  use LinkBuilderWeb, :controller

  alias LinkBuilder.Accounts
  alias LinkBuilder.Accounts.Account
  alias LinkBuilderWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_account_registration(%Account{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, %{users: [user]} = _account} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Account created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
