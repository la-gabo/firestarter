defmodule Firestarter.Repo.Migrations.AddListIdToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :list_id, references(:lists, on_delete: :nilify_all)
    end
  end
end
