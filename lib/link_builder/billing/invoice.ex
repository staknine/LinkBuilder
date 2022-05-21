defmodule LinkBuilder.Billing.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "billing_invoices" do
    field :status, :string
    field :stripe_id, :string
    field :subtotal, :integer
    field :currency, :string
    field :invoice_pdf, :string
    field :hosted_invoice_url, :string

    belongs_to :customer, LinkBuilder.Billing.Customer

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:stripe_id, :status, :hosted_invoice_url, :subtotal, :invoice_pdf, :currency])
    |> validate_required([:stripe_id, :status])
    |> unique_constraint(:stripe_id, name: :billing_invoices_stripe_id_index)
  end
end
