defmodule LinkBuilderWeb.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      _ ->
        conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{account: account, user: user}, _claims} <-
           LinkBuilder.Accounts.Guardian.resource_from_token(token) do
      {:ok, %{current_user: user, current_account: account, token: token}}
    end
  end
end
