defmodule FirestarterWeb.SessionController do
  use FirestarterWeb, :controller

  alias Firestarter.Accounts

  # POST /api/sessions
  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        jwt_claims = %{user_id: user.id}
        {:ok, access_token, _full_claims} = FirestarterWeb.Guardian.encode_and_sign(user, jwt_claims)
        {:ok, refresh_token} = Accounts.generate_refresh_token(user)
        max_age = 30 * 24 * 60 * 60 # Example: 30 days in seconds

        conn
        |> put_session(:user_id, user.id) # Store user ID in session
        |> put_session(:access_token, access_token) # Store access token in session
        |> put_resp_cookie("refresh_token", refresh_token, http_only: true, secure: true, max_age: max_age)
        |> redirect(to: "/tasks") # Redirect to tasks page after successful login
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Accounts.exchange_refresh_token_for_jwt(refresh_token) do
      {:ok, jwt} ->
        json(conn, %{jwt: jwt})
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Could not refresh the JWT"})
    end
  end

  # DELETE /api/sessions
  def delete(conn, %{"refresh_token" => refresh_token}) do
    case Accounts.revoke_refresh_token(refresh_token) do
      :ok ->
        conn
        |> put_status(:ok)
        |> json(%{message: "User logged out successfully"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Refresh token not found"})

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not revoke the refresh token"})
    end
  end
end
