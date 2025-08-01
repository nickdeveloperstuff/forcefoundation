defmodule Forcefoundation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ForcefoundationWeb.Telemetry,
      Forcefoundation.Repo,
      {DNSCluster, query: Application.get_env(:forcefoundation, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Forcefoundation.PubSub},
      # Start a worker by calling: Forcefoundation.Worker.start_link(arg)
      # {Forcefoundation.Worker, arg},
      # Start to serve requests, typically the last entry
      ForcefoundationWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :forcefoundation]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Forcefoundation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ForcefoundationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
