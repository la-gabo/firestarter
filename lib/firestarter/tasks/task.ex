defmodule Firestarter.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  # still need to associate tasks
  # with users, create auth fallbacks/catch

  schema "tasks" do
    field :title, :string
    field :completed, :boolean, default: false
    field :rank, :string

    timestamps()
  end

  @doc """
  Creates a changeset for a Task with the given attributes.
  Validates that the title is present and has a length between 3 and 100 characters.
  """
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :completed, :rank])
    |> validate_required([:title, :rank])
    |> validate_length(:title, min: 3, max: 100)
  end
end
