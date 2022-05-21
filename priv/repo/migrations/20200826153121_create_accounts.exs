defmodule LinkBuilder.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :token, :string, null: false

      timestamps()
    end

    create unique_index(:accounts, [:token])
  end
end
