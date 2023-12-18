defmodule Firestarter.Repo.Migrations.AddStatusToLists do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :status, :string, default: "active"
    end
  end
end
