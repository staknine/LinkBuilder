defmodule LinkBuilder.Repo.Migrations.CreateBillingCustomers do
  use Ecto.Migration

  def change do
    create table(:billing_customers) do
      add :stripe_id, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:billing_customers, [:account_id])
    create unique_index(:billing_customers, :stripe_id)
  end
end
