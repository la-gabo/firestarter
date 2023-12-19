defmodule Firestarter.Repo.Migrations.AddPermissions do
  use Ecto.Migration

  def change do
    # Create permissions table
    create table(:permissions) do
      add :level, :string, null: false
      timestamps()
    end

    # Ensure unique permission levels
    create unique_index(:permissions, [:level])

    # Insert default permissions
    execute "INSERT INTO permissions (level, inserted_at, updated_at) VALUES ('MANAGE', NOW(), NOW()), ('WRITE', NOW(), NOW()), ('READ', NOW(), NOW())"

    # Alter users table to include permission_id
    alter table(:users) do
      add :permission_id, references(:permissions, on_delete: :nothing)
    end

    # Set default permission to READ for existing users
    # Replace 'read_permission_id' with the actual ID from the inserted permissions
    read_permission_id = 3 # Assuming 'READ' permission has ID 3
    execute "UPDATE users SET permission_id = #{read_permission_id} WHERE permission_id IS NULL"
  end
end
