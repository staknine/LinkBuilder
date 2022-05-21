defmodule LinkBuilder.Accounts.Account do
  use LinkBuilder.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :token, :string
    field :card_brand, :string
    field :card_exp_month, :integer
    field :card_exp_year, :integer
    field :card_last4, :string

    has_many :users, LinkBuilder.Accounts.User
    has_one :billing_customer, LinkBuilder.Billing.Customer

    timestamps()
  end

  @doc """
  This is only used when an account is first created
  """
  def registration_changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :card_brand, :card_last4, :card_exp_year, :card_exp_month])
    |> validate_required([:name])
    |> cast_assoc(:users, with: {LinkBuilder.Accounts.User, :registration_changeset, []})
    |> set_token(account)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :card_brand, :card_last4, :card_exp_year, :card_exp_month])
    |> validate_required([:name])
    |> set_token(account)
  end

  # TODO: Remove. Not needed.
  defp set_token(changeset, %{token: "" <> _}), do: changeset
  defp set_token(changeset, _struct) do
    token = create_token()
    put_change(changeset, :token, token)
  end

  defp create_token(length \\ 20) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
