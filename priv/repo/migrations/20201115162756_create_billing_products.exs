defmodule LinkBuilder.Repo.Migrations.CreateBillingProducts do
  use Ecto.Migration

  def change do
    create table(:billing_products) do
      add :stripe_id, :string
      add :name, :string
      add :active, :boolean, default: true, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:billing_products, :stripe_id)
  end
end
