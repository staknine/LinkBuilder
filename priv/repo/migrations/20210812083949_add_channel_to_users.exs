defmodule LinkBuilder.Repo.Migrations.AddChannelToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :channel_name, :string
    end
  end
end
