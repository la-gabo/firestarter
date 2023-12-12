defmodule Firestarter.Tasks.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string
    field :rank, :decimal

    has_many :tasks, Firestarter.Tasks.Task, foreign_key: :list_id
    belongs_to :owner, Firestarter.Accounts.User, foreign_key: :user_id

    timestamps()
  end

  @doc """
  Changeset function for List.
  """
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :rank, :user_id])
    |> validate_required([:title, :user_id])
    |> validate_length(:title, min: 3, max: 100)
  end
end
