defmodule FirestarterWeb.TaskController do
  use FirestarterWeb, :controller

  alias Firestarter.Tasks
  alias Firestarter.Tasks.Task

  action_fallback FirestarterWeb.FallbackController

  @doc """
  Lists all tasks.

  ## Parameters

    - conn: The connection struct
    - _params: A map of parameters (unused in this function)
  """
  def index(conn, _params) do
    tasks = Tasks.list_tasks()
    render(conn, "index.json", tasks: tasks)
  end

  @doc """
  Creates a new task and renders the task if successful.

  ## Parameters

    - conn: The connection struct
    - "task": A map containing the task params
  """
  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- Tasks.create_task(task_params) do
      conn
      |> put_status(:created)
      |> render("show.json", task: task)
    end
  end

  @doc """
  Shows a specific task based on the ID provided.

  ## Parameters

    - conn: The connection struct
    - "id": The ID of the task to show
  """
  def show(conn, %{"id" => id}) do
    case Tasks.get_task(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Task not found"})
      task ->
        render(conn, "show.json", task: task)
    end
  end

  @doc """
  Updates a task and renders the updated task if successful.

  ## Parameters

    - conn: The connection struct
    - "id": The ID of the task to update
    - "task": A map containing the updated task params
  """
  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task(id)

    with {:ok, %Task{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, "show.json", task: task)
    end
  end

  @doc """
  Deletes a task based on the ID provided.

  ## Parameters

    - conn: The connection struct
    - "id": The ID of the task to delete
  """
  def delete(conn, %{"id" => id}) do
    case Tasks.get_task(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "Task not found"})
      task ->
        case Tasks.delete_task(task) do
          {:ok, _task} ->
            send_resp(conn, :no_content, "")
          {:error, _changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{message: "Unable to delete task"})
        end
    end
  end
end
