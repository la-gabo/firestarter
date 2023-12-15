defmodule Firestarter.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Firestarter.Repo

  alias Firestarter.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  def list_tasks_for_user(user_id) do
    from(t in Task, where: t.user_id == ^user_id, order_by: t.rank) |> Repo.all()
  end

  def list_tasks_for_list(user_id) do
    from(t in Task, where: t.user_id == ^user_id , order_by: t.rank) |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task(id) do
    Repo.get(Task, id)
  end

  def get_task_for_user(task_id, user_id) do
    Repo.get_by(Task, [id: task_id, user_id: user_id])
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    # Ensure attrs keys are atoms
    atom_attrs = Enum.into(attrs, %{}, fn {k, v} -> {String.to_existing_atom(k), v} end)
    user_id = atom_attrs[:user_id]

    # Get the task with the highest rank for the user
    highest_rank_task =
      Task
      |> where([t], t.user_id == ^user_id)
      |> order_by([t], desc: t.rank)
      |> limit(1)
      |> Repo.one()

    new_rank = compute_new_rank_for_creation(highest_rank_task)

    %Task{}
    |> Task.changeset(Map.put(atom_attrs, :rank, new_rank))
    |> Repo.insert()
  end

  defp compute_new_rank_for_creation(nil), do: "10000" # Default rank for first task
  defp compute_new_rank_for_creation(task), do: Integer.to_string(String.to_integer(task.rank) + 1000)

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Reorders a task based on the provided above and below task IDs.
  """
  def reorder_task(task_id, above_id, below_id, list_id) do
    task = Repo.get(Task, task_id)

    # Fetch the tasks immediately above and below the one being moved
    above_task = if above_id, do: Repo.get(Task, above_id), else: nil
    below_task = if below_id, do: Repo.get(Task, below_id), else: nil

    new_rank = compute_new_rank(above_task, below_task)

    IO.inspect(list_id, label: "++WUW")

    task
    |> Task.changeset(%{rank: new_rank, list_id: list_id})
    |> Repo.update()
  end


  defp compute_new_rank(nil, nil), do: "1000" # Initial rank when no tasks are present

  defp compute_new_rank(above_task, nil) do
    increment_rank(above_task.rank, 1000)
  end

  defp compute_new_rank(nil, below_task) do
    decrement_rank(below_task.rank, 1000)
  end

  defp compute_new_rank(above_task, below_task) do
    above_rank = String.to_integer(above_task.rank)
    below_rank = String.to_integer(below_task.rank)

    # Compute the average and ensure it's even
    average_rank = div(above_rank + below_rank, 2)
    new_rank = if rem(average_rank, 2) == 0, do: average_rank, else: average_rank + 1

    # Ensure the new rank is unique
    ensure_unique_rank(new_rank)
  end

  defp increment_rank(rank, _value) do
    # Increment by 10 ensuring the new rank is unique and even
    new_rank = String.to_integer(rank) + 10
    ensure_unique_rank(new_rank)
  end

  defp decrement_rank(rank, _value) do
    # Decrement by 10 ensuring the new rank is unique and even
    new_rank = String.to_integer(rank) - 10
    ensure_unique_rank(new_rank)
  end

  defp ensure_unique_rank(rank) do
    # Check if the rank exists in the database
    exists = Repo.exists?(from(t in Task, where: t.rank == ^Integer.to_string(rank)))

    if exists do
      # If it exists, increment or decrement by 2 until a unique even rank is found
      find_unique_even_rank(rank)
    else
      Integer.to_string(rank)
    end
  end

  defp find_unique_even_rank(rank) do
    new_rank = rank + 2
    exists = Repo.exists?(from(t in Task, where: t.rank == ^Integer.to_string(new_rank)))
    if exists, do: find_unique_even_rank(new_rank), else: Integer.to_string(new_rank)
  end
end
