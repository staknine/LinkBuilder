defmodule LinkBuilder.Repo.Migrations.CreateBillingPlans do
  use Ecto.Migration

  def change do
    create table(:billing_plans) do
      add :stripe_id, :string
      add :name, :string
      add :amount, :integer
      add :currency, :string
      add :interval, :string
      add :interval_count, :integer
      add :usage_type, :string
      add :trial_period_days, :integer
      add :active, :boolean, default: true, null: false
      add :nickname, :string
      add :billing_product_id, references(:billing_products, on_delete: :nothing)

      timestamps()
    end

    create index(:billing_plans, [:billing_product_id])
    create unique_index(:billing_plans, :stripe_id)
  end
end
