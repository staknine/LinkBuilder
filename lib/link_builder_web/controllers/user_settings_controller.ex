defmodule LinkBuilderWeb.UserSettingsController do
  use LinkBuilderWeb, :controller

  alias LinkBuilder.Accounts

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.app_user_edit_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.app_user_edit_path(conn, :edit))
    end
  end
end
