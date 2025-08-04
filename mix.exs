defmodule Forcefoundation.MixProject do
  use Mix.Project

  def project do
    [
      app: :forcefoundation,
      version: "0.1.0",
      elixir: "== 1.18.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      consolidate_protocols: Mix.env() != :dev
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Forcefoundation.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:usage_rules, "== 0.1.23"},
      {:bcrypt_elixir, "== 3.3.2"},
      {:picosat_elixir, "== 0.2.3"},
      {:sourceror, "== 1.10.0"},
      {:ash_cloak, "== 0.1.6"},
      {:cloak, "== 1.1.4"},
      {:ash_ai, "== 0.2.9"},
      {:ash_paper_trail, "== 0.5.6"},
      {:tidewave, "== 0.2.0", only: [:dev]},
      {:ash_events, "== 0.4.3"},
      {:ash_state_machine, "== 0.2.12"},
      {:ash_admin, "== 0.13.13"},
      {:ash_authentication_phoenix, "== 2.10.5"},
      {:ash_authentication, "== 4.9.9"},
      {:ash_postgres, "== 2.6.14"},
      {:ash_phoenix, "== 2.3.12"},
      {:ash, "== 3.5.33"},
      {:igniter, "== 0.6.25"},
      {:phoenix, "== 1.8.0-rc.4", override: true},
      {:phoenix_ecto, "== 4.6.5"},
      {:ecto_sql, "== 3.13.2"},
      {:postgrex, "== 0.21.0"},
      {:phoenix_html, "== 4.2.1"},
      {:phoenix_live_reload, "== 1.6.0", only: :dev},
      {:phoenix_live_view, "== 1.1.2"},
      {:lazy_html, "== 0.1.3", only: :test},
      {:phoenix_live_dashboard, "== 0.8.7"},
      {:esbuild, "== 0.10.0", runtime: Mix.env() == :dev},
      {:tailwind, "== 0.3.1", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "== 1.19.5"},
      {:req, "== 0.5.15"},
      {:telemetry_metrics, "== 1.1.0"},
      {:telemetry_poller, "== 1.3.0"},
      {:gettext, "== 0.26.2"},
      {:jason, "== 1.4.4"},
      {:dns_cluster, "== 0.2.0"},
      {:bandit, "== 1.7.0"}
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
      setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind forcefoundation", "esbuild forcefoundation"],
      "assets.deploy": [
        "tailwind forcefoundation --minify",
        "esbuild forcefoundation --minify",
        "phx.digest"
      ]
    ]
  end
end
