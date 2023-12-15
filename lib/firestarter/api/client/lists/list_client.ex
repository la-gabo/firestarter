defmodule Firestarter.ListClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug Tesla.Middleware.JSON

  @doc """
  Fetch all tasks for a specific user, using the access token for authentication.
  """
  def fetch_user_lists(access_token) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    get("/lists", headers: headers)
  end

  @doc """
  Create a new task for a user.
  """
  def create_user_list(access_token, list_params) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    post("/lists", %{list: list_params}, headers: headers)
  end

  @doc """
  Update a specific task for a user.
  """
  def update_user_list(access_token, list_id, list_params) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    put("/lists/#{list_id}", %{task: list_params}, headers: headers)
  end

  @doc """
  Delete a specific task for a user.
  """
  def delete_user_list(access_token, list_id) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    delete("/lists/#{list_id}", headers: headers)
  end
end
