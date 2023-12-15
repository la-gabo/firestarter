defmodule FirestarterWeb.ListController do
  use FirestarterWeb, :controller

  alias Firestarter.Lists

  action_fallback FirestarterWeb.FallbackController

  def index(conn, _params) do
    lists = Lists.list_lists()
    render(conn, "index.json", lists: lists)
  end

  def create(conn, %{"list" => list_params}) do
    case get_user_id_from_token(conn) do
      {:ok, user_id} ->
        # Merge the user_id into the list_params
        updated_list_params = Map.put(list_params, "user_id", user_id)
        case Lists.create_list(updated_list_params) do
          {:ok, list} -> render(conn, "show.json", list: list)
          {:error, changeset} -> respond_with_changeset(conn, changeset)
        end
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
    end
  end

  def show(conn, %{"id" => id}) do
    case Lists.get_list!(id) do
      nil -> send_resp(conn, :not_found, "List not found")
      list -> render(conn, "show.json", list: list)
    end
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    case Lists.update_list(id, list_params) do
      {:ok, list} -> render(conn, "show.json", list: list)
      {:error, changeset} -> respond_with_changeset(conn, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Lists.delete_list(id) do
      {:ok, _list} -> send_resp(conn, :no_content, "")
      {:error, :not_found} -> send_resp(conn, :not_found, "List not found")
    end
  end

  # Add this helper function to handle changeset errors
  defp respond_with_changeset(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(FirestarterWeb.ChangesetView, "error.json", changeset: changeset)
  end

  defp get_user_id_from_token(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil -> {:error, :no_user}
      user -> {:ok, user.id}
    end
  end
end
