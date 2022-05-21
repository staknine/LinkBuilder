defmodule LinkBuilder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    create_stripe_customer_service =
      if Application.get_env(:link_builder, :env) == :test,
        do: LinkBuilder.Billing.CreateStripeCustomer.Stub,
        else: LinkBuilder.Billing.CreateStripeCustomer

    webhook_processor_service =
      if Application.get_env(:link_builder, :env) == :test,
        do: LinkBuilder.Billing.WebhookProcessor.Stub,
        else: LinkBuilder.Billing.WebhookProcessor

    children = [
      # Start the Ecto repository
      LinkBuilder.Repo,
      # Start the Telemetry supervisor
      LinkBuilderWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LinkBuilder.PubSub},
      # Start the Endpoint (http/https)
      LinkBuilderWeb.Endpoint,
      # Start a worker by calling: LinkBuilder.Worker.start_link(arg)
      # {LinkBuilder.Worker, arg}
      {Oban, oban_config()},

      create_stripe_customer_service,
      webhook_processor_service
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LinkBuilder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LinkBuilderWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    Application.fetch_env!(:link_builder, Oban)
  end
end
