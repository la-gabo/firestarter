defmodule FirestarterWeb.SessionController do
  use FirestarterWeb, :controller

  alias Firestarter.Accounts

  # POST /api/sessions
  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = FirestarterWeb.Guardian.encode_and_sign(user)
        json(conn, %{jwt: jwt})

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  # DELETE /api/sessions
  def delete(conn, _) do
    # Here you would handle logout logic, like revoking tokens or clearing session data
    json(conn, %{message: "User logged out successfully"})
  end
end
