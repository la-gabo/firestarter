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

    highest_rank =
      Task
      |> where([t], t.user_id == ^user_id)
      |> select([t], max(type(t.rank, :integer)))
      |> Repo.one()

    new_rank = Integer.to_string((highest_rank || 0) + 1)

    %Task{}
    |> Task.changeset(Map.put(atom_attrs, :rank, new_rank))
    |> Repo.insert()
  end


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

  # def reorder_task(id, above_id, below_id) do
  #   above_task = get_task(above_id)
  #   below_task = get_task(below_id)
  #   new_rank = Firestarter.Tasks.Ranking.generate_rank(above_task.rank, below_task.rank)

  #   task = Repo.get!(Task, id)
  #   changeset = Task.changeset(task, %{rank: new_rank})

  #   Repo.update(changeset)
  # end
end
