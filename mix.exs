defmodule LinkBuilder.MixProject do
  use Mix.Project
  def project do
    [
      app: :link_builder,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end
  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LinkBuilder.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end
  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support/fixtures"]
  defp elixirc_paths(_), do: ["lib"]
  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:absinthe, "~> 1.6.5"},
      {:absinthe_plug, "~> 1.5.8"},
      {:bcrypt_elixir, "~> 2.0"},
      {:contex, "~> 0.4"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_psql_extras, "~> 0.6"},
      {:faker, "~> 0.16", only: [:dev, :test]},
      {:filtrex, "~> 0.4.3"},
      {:floki, ">= 0.30.0"},
      {:gen_smtp, "~> 1.0"},
      {:guardian, "~> 2.0"},
      {:money, "~> 1.9"},
      {:oban, "~> 2.10.1"},
      {:phoenix_swoosh, "~> 1.0.0"},
      {:premailex, "~> 0.3.0"},
      {:saas_kit, "~> 0.1.1", organization: "fullstackphoenix"},
      {:scrivener_ecto, "~> 2.0"},
      {:sobelow, "~> 0.8", only: :dev},
      {:stripity_stripe, "~> 2.0"},
      {:swoosh, "~> 1.5"},
      {:timex, "~> 3.7"},
      {:wallaby, "~> 0.29.1", runtime: false, only: :test},

      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.17.0"},
      {:phoenix_html, "~> 3.1.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
    ]
  end
  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "deps.get": ["hex.organization auth fullstackphoenix --key 434b538633a25ebdb352d93651f8f10c", "deps.get"],
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
