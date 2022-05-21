defmodule LinkBuilder.Repo.Migrations.AddCardDataToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :card_brand, :string
      add :card_exp_month, :integer
      add :card_exp_year, :integer
      add :card_last4, :string
    end
  end
end
