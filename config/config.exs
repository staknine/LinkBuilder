# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :link_builder,
  ecto_repos: [LinkBuilder.Repo],
  generators: [binary_id: true]

config :link_builder, LinkBuilder.Repo,
  migration_primary_key: [name: :id, type: :binary_id]

config :link_builder,
  stripe_service: Stripe,
  require_subscription: false,
  require_user_confirmation: true,
  app_name: "LinkBuilder",
  page_url: "link_builder.com",
  company_name: "LinkBuilder Inc",
  company_address: "26955 Fritsch Bridge",
  company_zip: "54933-7180",
  company_city: "San Fransisco",
  company_state: "California",
  company_country: "United States",
  contact_name: "John Doe",
  contact_phone: "+1 (335) 555-2036",
  contact_email: "john.doe@link_builder.com",
  from_email: "john.doe@link_builder.com"

# Configures the endpoint
config :link_builder, LinkBuilderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Yd0ejdhGhAbYRR7ahRiZJzcJhfdJSc1GQuRGDw8U+rJkGoNtYUkNxnTpo8LKl19d",
  render_errors: [view: LinkBuilderWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LinkBuilder.PubSub,
  live_view: [signing_salt: "EpuvXqeE"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.26",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.0.18",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :link_builder, LinkBuilder.Mailer, adapter: Swoosh.Adapters.Local

# Used for using a local client like Mailcatcher
# Mailcatcher is great when testing the emails in IEX
# config :link_builder, LinkBuilder.Mailer,
#   adapter: Swoosh.Adapters.SMTP,
#   relay: "127.0.0.1",
#   port: 1025

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET"),
  public_key: System.get_env("STRIPE_PUBLIC"),
  webhook_signing_key: System.get_env("STRIPE_WEBHOOK_SIGNING_KEY")

config :link_builder, LinkBuilder.Admins.Guardian,
  issuer: "link_builder",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY_ADMINS") || "Mg7qiGXmhXOdlj5pJGqgKtTyNL27VpHqxJKjdn7M22KXeuRzALThx8hkCICmmsze"

config :link_builder, LinkBuilder.Accounts.Guardian,
  issuer: "link_builder",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY") || "1u0zsXE0gk4mvO6rpU5BkkZkdAxZvygdUNsvtzBKVC182Y0nOusBhHWx6zSFI1j4"

config :link_builder, Oban,
  repo: LinkBuilder.Repo,
  queues: [default: 10, mailers: 20, high: 50, low: 5],
  plugins: [
    {Oban.Plugins.Pruner, max_age: (3600 * 24)},
    {Oban.Plugins.Cron,
      crontab: [
       # {"0 2 * * *", LinkBuilder.Workers.DailyDigestWorker},
       {"@reboot", LinkBuilder.Workers.StripeSyncWorker}
     ]}
  ]

config :saas_kit,
  otp_app: :link_builder,
  main_module: LinkBuilder,
  api_key: System.get_env("SAAS_KIT_API_KEY")

config :link_builder, :env, Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
