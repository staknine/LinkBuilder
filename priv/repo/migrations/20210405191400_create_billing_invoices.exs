defmodule LinkBuilder.Repo.Migrations.CreateBillingInvoices do
  use Ecto.Migration

  def change do
    create table(:billing_invoices, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :stripe_id, :string
      add :customer_id, references(:billing_customers, on_delete: :nothing)
      add :status, :string
      add :currency, :string
      add :invoice_pdf, :string
      add :hosted_invoice_url, :string
      add :subtotal, :integer

      timestamps()
    end

    create index(:billing_invoices, [:customer_id])
    create unique_index(:billing_invoices, :stripe_id)
  end
end
