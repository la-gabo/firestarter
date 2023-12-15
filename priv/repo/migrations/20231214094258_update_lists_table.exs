defmodule Firestarter.Repo.Migrations.UpdateListsTable do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :rank, :string
      add :user_id, references(:users, on_delete: :delete_all)
    end

    rename table(:lists), :name, to: :title
  end
end
