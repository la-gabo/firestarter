defmodule FirestarterWeb.AuthErrorHandler do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> put_resp_content_type("application/json")
    |> json(%{error: :unathorized})
  end
end
