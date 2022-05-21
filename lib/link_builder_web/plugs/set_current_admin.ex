defmodule LinkBuilderWeb.Plugs.SetCurrentAdmin do
  import Plug.Conn, only: [assign: 3, put_session: 3]

  alias LinkBuilder.Admins.Admin

  def init(options), do: options

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      %Admin{} = admin ->
        conn
        |> assign(:current_admin, admin)
        |> put_session(:current_admin_id, admin.id)
      _ -> conn
    end
  end
end
