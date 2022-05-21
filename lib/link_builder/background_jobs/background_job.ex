defmodule LinkBuilder.BackgroundJobs.BackgroundJob do
  use Ecto.Schema

  schema "oban_jobs" do
    field :args, :map
    field :attempt, :integer
    field :attempted_at, :naive_datetime
    field :completed_at, :naive_datetime
    field :max_attempts, :integer
    field :queue, :string
    field :scheduled_at, :naive_datetime
    field :state, :string
    field :worker, :string
  end
end
