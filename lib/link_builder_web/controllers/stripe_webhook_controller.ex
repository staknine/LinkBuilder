defmodule LinkBuilderWeb.StripeWebhookController do
  use LinkBuilderWeb, :controller

  @webhook_signing_key Application.get_env(:stripity_stripe, :webhook_signing_key)
  @stripe_service Application.get_env(:link_builder, :stripe_service)

  plug :assert_body_and_signature

  def create(conn, _params) do
    case @stripe_service.Webhook.construct_event(conn.assigns[:raw_body], conn.assigns[:stripe_signature], @webhook_signing_key) do
      {:ok, %{} = event} -> notify_subscribers(event)
      {:error, reason} -> reason
    end

    conn
    |> send_resp(:created, "")
  end

  def notify_subscribers(event) do
    Phoenix.PubSub.broadcast(LinkBuilder.PubSub, "webhook_received", %{event: event})
  end

  def subscribe_on_webhook_recieved do
    Phoenix.PubSub.subscribe(LinkBuilder.PubSub, "webhook_received")
  end

  defp assert_body_and_signature(conn, _opts) do
    case {conn.assigns[:raw_body], conn.assigns[:stripe_signature]} do
      {"" <> _, "" <> _} ->
        conn
      _ ->
        conn
        |> send_resp(:created, "")
        |> halt()
    end
  end
end
