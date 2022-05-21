defmodule LinkBuilder.Workers.StripeSyncWorker do
  @moduledoc """
  Syncs products and plans with Stripe
  """
  use Oban.Worker

  alias LinkBuilder.Billing.SynchronizeProducts
  alias LinkBuilder.Billing.SynchronizePlans

  @impl Oban.Worker
  def perform(_job) do
    case Application.fetch_env(:stripity_stripe, :api_key) do
      {:ok, _ } ->
        SynchronizeProducts.run()
        SynchronizePlans.run()
      _ ->
        nil
    end

    :ok
  end
end
