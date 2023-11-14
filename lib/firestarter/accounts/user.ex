defmodule Firestarter.Accounts.User do
  @moduledoc """
  Defines the user schema and encapsulates user-related changesets.

  The schema includes fields for `email`, `password_hash`, and a virtual
  `password` field for accepting user password inputs.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @doc """
  Defines the schema for the `users` table.
  """
  schema "users" do
    field :email, :string
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true, redact: true

    timestamps()
  end

  @doc """
  Generates a changeset based on the user schema and form parameters.

  ## Parameters

    - `user`: The user data structure to apply the changes to.
    - `attrs`: The form parameters to cast and validate.

  ## Examples

      iex> changeset(user, %{"email" => "user@example.com", "password" => "passw0rd"})
      %Ecto.Changeset{...}

  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password()
    |> unique_constraint(:email, message: "This email is already taken.")
  end


  @doc false
  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/, message: "Please enter valid email.")
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_format(:password, ~r/(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}/,
        message: "Password must include at least one uppercase letter, one lowercase letter, one number, and one special character.")
  end
end
