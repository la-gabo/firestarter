defmodule Firestarter.Repo.Migrations.AddListsTable do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :name, :string

      timestamps()
    end
  end
end
