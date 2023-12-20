defmodule FirestarterWeb.Plugs.CurrentUser do
  import Plug.Conn
  alias Firestarter.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id) || decode_and_verify_jwt(conn)
    IO.inspect(user_id, label: "User ID")

    if user_id do
      try do
        user = Accounts.get_user!(user_id)
        IO.inspect(user, label: "User found")
        assign(conn, :current_user, user)
      rescue
        Ecto.NoResultsError ->
          IO.puts("No user found for ID: #{user_id}")
          conn
      end
    else
      IO.puts("No user_id in session or JWT")
      conn
    end
  end

  defp decode_and_verify_jwt(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
        {:ok, claims} <- FirestarterWeb.Guardian.decode_and_verify(token),
        "User" = claims["typ"],
        user_id <- claims["sub"] do
      String.to_integer(user_id)
    else
      _ -> nil
    end
  end
end
