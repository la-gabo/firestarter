defmodule FirestarterWeb.FooLive do
  use FirestarterWeb, :live_view

  # mount
  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
    {:ok, socket}
  end

  # render
  def render(assigns) do
    ~H"""
      <h1>Front porch light</h1>
      <div class="light">
        <div class="meter">
          <span style={"width: #{@brightness}%"}>
            <%= @brightness %>%
          </span>
        </div>
      </div>
    """
  end

  # handle_event
end
