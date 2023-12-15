defmodule FirestarterWeb.ShowroomLive do
  use FirestarterWeb, :live_view
  alias FirestarterWeb.CoreComponents, as: FUI

  def mount(_params, _session, socket) do
    checkbox_field = %{id: "checkbox1", value: "checkbox_value"}
    checkbox_items = [
      %{id: "checkbox1", value: "Option 1", text: "Option 1"},
      %{id: "checkbox2", value: "Option 2", text: "Option 2"},
      # ... other checkboxes
    ]

    socket =
      socket
      |> assign(:checkbox_field, checkbox_field)
      |> assign(:checkbox_items, checkbox_items)
      |> assign(:form, nil)

    {:ok, socket}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    IO.puts("TYPING...")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <FUI.container class="p-4 flex-col flex gap-2" title="Text Header">
        <form for={@form} phx-submit="save">
          <input placeholder="Username goes here..." type="text" field={@form[:username]} />
          <input placeholder="Email goes here..." type="email" field={@form[:email]} />
          <button>Save</button>
        </form>
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Text Header">
        <FUI.text_header text="Firestarter" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Text Subheader">
        <FUI.text_subheader text="Firestarter" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Text Regular">
        <FUI.text_regular text="Firestarter" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Avatar Icon">
        <div class="flex gap-2">
          <FUI.avatar_icon initials="SF" />
          <FUI.avatar_icon initials="GO" />
        </div>
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Input">
        <FUI.input_with_icon phx_change="search" placeholder="Search..." icon="search-icon-class" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Icon buttons">
        <div class="flex gap-2">
          <FUI.outline_button_with_icon
            phx_click="show_people"
            icon_name={:users}
            text="People"
          />
          <div class="flex gap-2">
          <FUI.outline_button_with_icon
            phx_click="show_labels"
            icon_name={:bookmark}
            text="Labels"
          />
        </div>
        </div>
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Card Container">
        <FUI.card_container />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Task Container">
        <FUI.card title="Card" description="Short description" tags={["Urgent", "Design"]} />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Textarea">
        <FUI.textarea />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Button">
        <FUI.button phx_click="click" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Dynamic Icon Button">
        <div class="flex gap-2">
            <FUI.icon_button phx_click="some_action" icon_name={:dots_horizontal} button_class="text-gray-500 hover:text-gray-700" />
        </div>
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Checkbox">
        <FUI.checkbox phx_change="check" field={@checkbox_field} text="Check this box" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Checkbox Group">
        <%= for item <- @checkbox_items do %>
          <FUI.checkbox phx_change="check-this" field={%{id: item.id, value: item.value}} text={item.text} group="checkbox_group" />
        <% end %>
      </FUI.container>
    </div>
    """
  end
end
