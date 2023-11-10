defmodule FirestarterWeb.PageController do
  use FirestarterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
