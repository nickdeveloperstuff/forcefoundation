import Config
config :forcefoundation, token_signing_secret: "balPfSbKzkiu64gdcr/rlRohS1pnnuSB"
config :bcrypt_elixir, log_rounds: 1
config :ash, policies: [show_policy_breakdowns?: true]

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :forcefoundation, Forcefoundation.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "forcefoundation_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :forcefoundation, ForcefoundationWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3aX9OZgF0ekBt4lMuE8Sqsmk9M9hwiQDDyqlhIbNksaRd4ksOMJJYrCHfouMcuR8",
  server: false

# In test we don't send emails
config :forcefoundation, Forcefoundation.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
