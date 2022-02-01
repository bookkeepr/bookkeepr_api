defmodule Bookkeepr.Repo do
  use Ecto.Repo,
    otp_app: :bookkeepr,
    adapter: Ecto.Adapters.Postgres
end
