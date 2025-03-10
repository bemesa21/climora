defmodule Climora.Repo do
  use Ecto.Repo,
    otp_app: :climora,
    adapter: Ecto.Adapters.Postgres
end
