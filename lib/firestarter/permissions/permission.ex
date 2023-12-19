defmodule Firestarter.Accounts.Permission do
  use Ecto.Schema

  @moduledoc """
  Defines the permission schema.
  """

  schema "permissions" do
    field :level, :string

    has_many :users, Firestarter.Accounts.User

    timestamps()
  end

  @valid_levels ["MANAGE", "WRITE", "READ"]

  def changeset(permission, attrs) do
    permission
    |> Ecto.Changeset.cast(attrs, [:level])
    |> Ecto.Changeset.validate_inclusion(:level, @valid_levels, message: "is not a valid permission level")
  end
end
