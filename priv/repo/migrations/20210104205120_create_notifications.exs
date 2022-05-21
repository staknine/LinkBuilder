defmodule LinkBuilder.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :string, null: false
      add :title, :string
      add :body, :text
      add :read_at, :naive_datetime
      add :discarded_at, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:notifications, [:user_id])
  end
end
