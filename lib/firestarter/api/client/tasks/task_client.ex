defmodule Firestarter.TaskClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://localhost:4000/api"
  plug Tesla.Middleware.JSON

  @doc """
  Fetch all tasks for a specific user, using the access token for authentication.
  """
  def fetch_user_tasks(access_token) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    get("/tasks", headers: headers)
  end

  @doc """
  Create a new task for a user.
  """
  def create_user_task(access_token, task_params) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    post("/tasks", %{task: task_params}, headers: headers)
  end

  @doc """
  Update a specific task for a user.
  """
  def update_user_task(access_token, task_id, task_params) do
    IO.inspect(task_params, label: "UPDATING")
    headers = [{"Authorization", "Bearer #{access_token}"}]
    put("/tasks/#{task_id}", %{task: task_params}, headers: headers)
  end

  @doc """
  Delete a specific task for a user.
  """
  def delete_user_task(access_token, task_id) do
    headers = [{"Authorization", "Bearer #{access_token}"}]
    delete("/tasks/#{task_id}", headers: headers)
  end
end
