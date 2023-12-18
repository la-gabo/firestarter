defmodule Firestarter.Tasks.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string
    field :rank, :string
    # Adding a default value for the status field
    field :status, :string, default: "active"

    has_many :tasks, Firestarter.Tasks.Task, foreign_key: :list_id
    belongs_to :owner, Firestarter.Accounts.User, foreign_key: :user_id

    timestamps()
  end

  @doc """
  Changeset function for List.
  """
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :rank, :user_id, :status]) # Include :status in the cast
    |> validate_required([:title, :user_id])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_status() # Custom validation for status
  end

  @doc """
  Custom validation for the status field.
  """
  defp validate_status(changeset) do
    valid_statuses = ["active", "archived"] # Define acceptable status values
    validate_inclusion(changeset, :status, valid_statuses)
  end
end
