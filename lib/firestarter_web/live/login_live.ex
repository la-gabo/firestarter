defmodule FirestarterWeb.LoginLive do
  use FirestarterWeb, :live_view

  def render(assigns) do
    ~L"""
    <h1>Login</h1>
    <form action="/api/sessions" method="post">
      <input type="text" name="email" placeholder="Email" value="<%= @email %>"/>
      <input type="password" name="password" placeholder="Password"/>
      <button type="submit">Login</button>
    </form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, email: "", password: "", error: nil)}
  end
end
