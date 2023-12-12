defmodule FirestarterWeb.ShowroomLive do
  use FirestarterWeb, :live_view
  alias FirestarterWeb.CoreComponents, as: FUI

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("inc", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <FUI.container class="p-4 flex-col flex gap-2" title="Text Header">
        <FUI.text_header text="Text Header" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Text Subheader">
        <FUI.text_subheader text="Text Subheader" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Text Regular">
        <FUI.text_regular text="Text Regular" />
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
          <FUI.outline_button_with_icon text="People" icon="people-icon-class" phx_click="show_people" />
          <FUI.outline_button_with_icon text="Labels" icon="label-icon-class" phx_click="show_labels" />
        </div>
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Card Container">
        <FUI.card_container />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Task Container">
        <FUI.card title="Card" description="Short description" tags={["Urgent", "Design"]} />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Task Container">
        <FUI.textarea phx_change="change" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Button">
        <FUI.button phx_click="click" />
      </FUI.container>

      <FUI.container class="p-4 flex-col flex gap-2" title="Dynamic Icon Button">
        <div class="flex gap-2">
          <!-- Replace :menu with any other icon name you wish to display -->
            <FUI.icon_button phx_click="some_action" icon_name={:dots_horizontal} button_class="text-gray-500 hover:text-gray-700" />
        </div>
      </FUI.container>
    </div>
    """
  end
end
