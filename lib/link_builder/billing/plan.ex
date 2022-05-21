defmodule LinkBuilder.Billing.Plan do
  use LinkBuilder.Schema
  import Ecto.Changeset

  schema "billing_plans" do
    field :amount, :integer
    field :stripe_id, :string
    field :name, :string
    field :currency, :string, default: "usd"
    field :interval, :string, default: "month"
    field :interval_count, :integer
    field :usage_type, :string
    field :trial_period_days, :integer
    field :active, :boolean, default: true
    field :nickname, :string

    belongs_to :product, LinkBuilder.Billing.Product, foreign_key: :billing_product_id
    has_many :subscriptions, LinkBuilder.Billing.Subscription

    timestamps()
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, [
      :stripe_id,
      :name,
      :amount,
      :currency,
      :interval,
      :interval_count,
      :usage_type,
      :trial_period_days,
      :active,
      :nickname
    ])
    |> validate_required([:name, :amount])
    |> unique_constraint(:stripe_id, name: :billing_plans_stripe_id_index)
  end
end
