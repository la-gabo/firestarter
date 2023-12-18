defmodule Firestarter.AccountClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug Tesla.Middleware.JSON

  @doc """
  Logs in a user and returns the response (including access token).
  """
  def login(email, password) do
    body = %{email: email, password: password}
    post("/sessions", body)
  end

  @doc """
  Fetches a list of all users.
  """
  def fetch_all_users(access_token) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    get("/users", headers: headers)
  end
end
