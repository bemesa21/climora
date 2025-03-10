defmodule Climora.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClimoraWeb.Telemetry,
      Climora.Repo,
      {DNSCluster, query: Application.get_env(:climora, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Climora.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Climora.Finch},
      # Start a worker by calling: Climora.Worker.start_link(arg)
      # {Climora.Worker, arg},
      # Start to serve requests, typically the last entry
      ClimoraWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Climora.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClimoraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
