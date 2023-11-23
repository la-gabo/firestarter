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
    case get_user_id_from_token(conn) do
      {:ok, user_id} ->
        tasks = Tasks.list_tasks_for_user(user_id)
        render(conn, "index.json", tasks: tasks)
      {:error, _reason} ->
        conn
        |> put_status(:unathorized)
        |> json(%{error: "unauthorized"})
    end
  end

  @doc """
  Creates a new task and renders the task if successful.

  ## Parameters

    - conn: The connection struct
    - "task": A map containing the task params
  """
  def create(conn, %{"task" => task_params}) do
    case get_user_id_from_token(conn) do
      {:ok, user_id} ->
        modified_task_params = Map.put(task_params, "user_id", user_id)
        with {:ok, %Task{} = task} <- Tasks.create_task(modified_task_params) do
          conn
          |> put_status(:created)
          |> render("show.json", task: task)
        end
      {:error, _reason} ->
        conn
        |> put_status(:unathorized)
        |> json(%{error: "Unathorized"})
    end
  end

  defp get_user_id_from_token(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil -> {:error, :no_user}
      user -> {:ok, user.id}
    end
  end

  @doc """
  Shows a specific task based on the ID provided.

  ## Parameters

    - conn: The connection struct
    - "id": The ID of the task to show
  """
  def show(conn, %{"id" => id}) do
    case get_user_id_from_token(conn) do
      {:ok, user_id} ->
        case Tasks.get_task_for_user(id, user_id) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{message: "Task not found or unauthorized"})
          task ->
            render(conn, "show.json", task: task)
        end
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unathorized"})
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

  # def reorder(conn, %{"id" => id, "above_id" => above_id, "below_id" => below_id}) do
  #   case Tasks.reorder_task(id, above_id, below_id) do
  #     {:ok, task} ->
  #       conn |> put_status(:ok) |> json(%{task: task})
  #     {:error, changeset} ->
  #       conn |> put_status(:unprocessable_entity) |> json(%{errors: changeset.errors})
  #   end
  # end
end
