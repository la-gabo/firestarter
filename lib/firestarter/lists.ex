defmodule Firestarter.Lists do
  @moduledoc """
  The Lists context.
  """

  import Ecto.Query, warn: false
  alias Firestarter.Repo

  alias Firestarter.Tasks.List

  @doc """
  Returns the list of lists.
  """
  def list_lists do
    Repo.all(List)
  end

  @doc """
  Gets a single list.
  """
  def get_list!(id) do
    Repo.get!(List, id)
  end

  @doc """
  Creates a list.
  """
  def create_list(attrs \\ %{}) do
    # Convert all keys to strings, handling both atoms and strings as keys
    string_attrs = Enum.into(attrs, %{}, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v} # if it's already a string, leave it as is
    end)

    # Default rank if not provided
    string_attrs = Map.put_new(string_attrs, "rank", "1")

    %List{}
    |> List.changeset(string_attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list.
  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list.
  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end
end
