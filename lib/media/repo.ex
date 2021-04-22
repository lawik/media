defmodule Media.Repo do
  use Ecto.Repo,
    otp_app: :media,
    adapter: Ecto.Adapters.Postgres
end
