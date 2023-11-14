defmodule Firestarter.Repo.Migrations.AddRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens) do
      add :token, :binary, null: false
      add :expires_at, :naive_datetime, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:refresh_tokens, [:token])
    create index(:refresh_tokens, [:user_id])
  end
end
