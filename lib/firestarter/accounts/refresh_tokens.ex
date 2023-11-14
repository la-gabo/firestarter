defmodule Firestarter.Accounts.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refresh_tokens" do
    field :token, :string
    field :expires_at, :naive_datetime
    belongs_to :user, Firestarter.Accounts.User

    timestamps()
  end

  @spec changeset(
          {map(), map()}
          | %{
              :__struct__ => atom() | %{:__changeset__ => map(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:token, :expires_at, :user_id])
    |> validate_required([:token, :expires_at, :user_id])
  end
end
