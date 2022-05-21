import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :link_builder, LinkBuilder.Repo,
  username: "postgres",
  password: "postgres",
  database: "link_builder_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  queue_target: 5000,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :link_builder, LinkBuilderWeb.Endpoint,
  http: [port: 4002],
  server: true

# In test we don't send emails.
config :link_builder, LinkBuilder.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

config :link_builder,
  stripe_service: MockStripe,
  require_subscription: false,
  require_user_confirmation: false

# Recommended to lower the iterations count in
# your test environment to speed up your tests
config :bcrypt_elixir, :log_rounds, 1

config :link_builder, LinkBuilder.Admins.Guardian,
  issuer: "link_builder",
  secret_key: "1RCGH+jnTgJNVrkKQMrebh6AOkYRLrpThEPM37fEIYHXtJCEvwAjdQwbRLv8GPWJ"

config :link_builder, LinkBuilder.Accounts.Guardian,
  issuer: "link_builder",
  secret_key: "hS5jzOOsnvcmGvhz6B1B+FfbtfKY2wvTxYSLC6CcC8WY2pNLsx59nEPwWOnwIAHL"

config :link_builder, Oban, queues: false, plugins: false
config :wallaby, otp_app: :link_builder
config :link_builder, :sandbox, Ecto.Adapters.SQL.Sandbox
