defmodule LinkBuilderWeb.Plugs.RequireActiveSubscription do
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  import Plug.Conn, only: [halt: 1, put_session: 3]

  alias LinkBuilder.Billing
  alias LinkBuilderWeb.Router.Helpers, as: Routes

  def init(options), do: options

  @doc """
  Used for routes that require the user to to have an active subscription.
  Note that this first looks for a current_user. If current_user is not
  found, it just returns conn and expects require_authenticated_user/2
  to handle it.
  This checks for a subscription on every request but the result could be stored
  a cookie.
  """
  def call(conn, _opts) do
    with "" <> _ <- Application.get_env(:stripity_stripe, :api_key),
         true <- Application.get_env(:link_builder, :require_subscription),
         %{} = account <- conn.assigns[:current_account],
         %{stripe_id: "" <> _} <- Billing.get_billing_customer_for_account(account)
    do
      LinkBuilder.Billing.get_active_subscription_for_account(account.id)
      |> handle_inactive_subscription(conn)

      conn
    else
      _ -> conn
    end
  end

  defp handle_inactive_subscription(%LinkBuilder.Billing.Subscription{}, conn), do: conn

  defp handle_inactive_subscription(_, conn) do
    case Application.get_env(:link_builder, :require_subscription) do
      false ->
        conn

      _ ->
        conn
        |> put_flash(:error, "You need an active subscription")
        |> maybe_store_return_to()
        |> redirect(to: Routes.subscription_new_path(conn, :new))
        |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    %{request_path: request_path, query_string: query_string} = conn
    return_to = if query_string == "", do: request_path, else: request_path <> "?" <> query_string
    put_session(conn, :user_return_to, return_to)
  end

  defp maybe_store_return_to(conn), do: conn
end
