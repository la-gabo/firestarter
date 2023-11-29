defmodule FirestarterWeb.ListComponent do
  use FirestarterWeb, :live_component
  import FirestarterWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="space-y-5 mx-auto max-w-7xl px-4 space-y-4">
        <.header>
          <%= @list_name %>
          <.simple_form
            phx_change="validate"
            phx_submit="save"
            phx_target={@myself}
          >
            <.input phx_change="validate" field={%{id: "new-task", label: @new_task_title, value: @new_task_title}} type="text" />
            <:actions>
              <.button phx_click="test" class="align-middle ml-2">
                <.icon class="test-class" name="test-plus-icon" />
              </.button>
            </:actions>
          </.simple_form>
        </.header>
        <div id={"#{@id}-items"}>
          <%= for item <- @list do %>
            <div id={"#{@id}-#{item["id"]}"}>
              <div class="flex">
                <button type="button" class="w-10">
                <.icon
                  name="check"
                  class={Enum.join([
                    "w-7 h-7",
                    if(item["status"] == :completed, do: "bg-green-600", else: "bg-gray-300")
                  ], " ")}
                />
                </button>
                <div class="flex-auto block text-sm leading-6 text-zinc-900">
                  <%= item["title"] %>
                </div>
                <button type="button" class="w-10 -mt-1 flex-none">
                  <.icon class="test-class" name="hero-x-mark" />
                </button>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
