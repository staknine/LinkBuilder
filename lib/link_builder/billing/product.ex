defmodule LinkBuilder.Billing.Product do
  use LinkBuilder.Schema
  import Ecto.Changeset

  schema "billing_products" do
    field :stripe_id, :string
    field :name, :string
    field :active, :boolean, default: true
    field :description, :string

    has_many :plans, LinkBuilder.Billing.Plan, foreign_key: :billing_product_id

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:stripe_id, :name, :active, :description])
    |> validate_required([:name])
    |> unique_constraint(:stripe_id, name: :billing_products_stripe_id_index)
  end
end
