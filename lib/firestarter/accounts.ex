defmodule Firestarter.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Firestarter.Repo

  alias Firestarter.Accounts.User
  alias Firestarter.Accounts.RefreshToken

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(from u in User, order_by: [asc: u.email], preload: [:permission])
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user with a hashed password.

  ## Examples

      iex> create_user(%{"email" => "user@example.com", "password" => "passw0rd"})
      {:ok, %User{}}

      iex> create_user(%{"email" => "user@example.com"})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(attrs \\ %{}) do
    changeset = User.changeset(%User{}, attrs)

    if changeset.valid? do
      hashed_password = Bcrypt.hash_pwd_salt(changeset.changes.password)
      changeset
      |> Ecto.Changeset.put_change(:password_hash, hashed_password)
      |> Repo.insert()
    else
      {:error, changeset}
    end
  end

   @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end


  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)
    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}
      true ->
        {:error, :unauthorized}
    end
  end

  def exchange_refresh_token_for_jwt(refresh_token) do
    with {:ok, user} <- verify_and_revoke_refresh_token(refresh_token),
        {:ok, jwt, _full_claims} <- FirestarterWeb.Guardian.encode_and_sign(user, %{}) do
      {:ok, jwt}
    else
      error -> {:error, error}
    end
  end

  # TODO: prevent timing attacks
  defp verify_and_revoke_refresh_token(refresh_token) do
    case Repo.get_by(RefreshToken, token: refresh_token) do
      nil -> {:error, :invalid_token}
      refresh_token ->
        # Assume that the expires_at is in UTC and convert it to DateTime
        expires_at_utc = DateTime.from_naive!(refresh_token.expires_at, "Etc/UTC")

        # Verify expiration
        if DateTime.compare(expires_at_utc, DateTime.utc_now()) == :gt do
          # Invalidate the current refresh token
          Repo.delete(refresh_token)

          # Preload the user if not already loaded
          user = Repo.preload(refresh_token, :user).user

          # Return the user associated with the refresh token
          {:ok, user}
        else
          {:error, :invalid_token}
        end
    end
  end

  @refresh_token_validity_secs 2_592_000 # 30 days in seconds

  def generate_refresh_token(user) do
    # Create a unique token string
    token = :crypto.strong_rand_bytes(64) |> Base.url_encode64()

    # Set an expiry date for the token
    expires_at = DateTime.add(DateTime.utc_now(), @refresh_token_validity_secs)

    # Save the token in the database associated with the user
    changeset = RefreshToken.changeset(%RefreshToken{}, %{
      token: token,
      expires_at: expires_at,
      user_id: user.id
    })

    case Repo.insert(changeset) do
      {:ok, _refresh_token} -> {:ok, token}
      {:error, _changeset} -> {:error, :could_not_create_token}
    end
  end

  def revoke_refresh_token(refresh_token_string) do
    case Repo.get_by(RefreshToken, token: refresh_token_string) do
      nil ->
        {:error, :not_found}

      refresh_token ->
        case Repo.delete(refresh_token) do
          {:ok, _} ->
            :ok

          {:error, reason} ->
            {:error, reason}
        end
    end
  end
end
