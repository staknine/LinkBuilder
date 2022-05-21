defmodule LinkBuilderWeb.Plugs.RequireCurrentAdmin do
  import Phoenix.Controller, only: [redirect: 2]
  import Plug.Conn, only: [halt: 1]

  alias LinkBuilderWeb.Router.Helpers, as: Routes
  alias LinkBuilder.Admins.Admin

  def init(options), do: options

  def call(conn, _opts) do
    case conn.assigns[:current_admin] do
      %Admin{} ->
        conn
      _ ->
        conn
        |> redirect(to: Routes.admin_session_path(conn, :new))
        |> halt()
    end
  end
end
