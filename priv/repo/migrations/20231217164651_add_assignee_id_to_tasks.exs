defmodule Firestarter.Repo.Migrations.AddAssigneeIdToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :assignee_id, references(:users, on_delete: :nothing), null: true
    end
  end
end
