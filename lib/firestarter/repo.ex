defmodule Firestarter.Repo do
  use Ecto.Repo,
    otp_app: :firestarter,
    adapter: Ecto.Adapters.Postgres
end
