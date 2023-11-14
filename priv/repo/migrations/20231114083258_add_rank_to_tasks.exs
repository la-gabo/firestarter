defmodule Firestarter.Repo.Migrations.AddRankToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :rank, :string
    end
  end
end
