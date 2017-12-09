# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :todo_with_auth,
  ecto_repos: [TodoWithAuth.Repo]

# Configures the endpoint
config :todo_with_auth, TodoWithAuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Nr6P2qfZI8X8y8Zmu/5tcdxuTGoxQHgS5wVMDMQ6C7w2Ee70mBgjRCKckngFVdis",
  render_errors: [view: TodoWithAuthWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TodoWithAuth.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Guardian configuration
config :todo_with_auth, TodoWithAuthWeb.Guardian,
  issuer: "TodoWithAuth",
  ttl: { 30, :days },
  allowed_drift: 2000,
  secret_key: "G5XlyVNL0H27ZY7tW4N/Jrt+4xvk0UYRxqOA2uksQm8qanQbbo7ojSN0+4FaC/Fv",
  serializer: TodoWithAuth.GuardianSerializer