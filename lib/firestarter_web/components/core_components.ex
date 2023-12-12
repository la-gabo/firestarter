defmodule FirestarterWeb.CoreComponents do
  use Phoenix.Component

  @doc """
  Renders a text header.
  """
  attr :text, :string, required: true
  attr :class, :string, default: "text-4xl font-bold"

  def text_header(assigns) do
    ~H"""
    <h2 class={@class}> <%= @text %> </h2>
    """
  end

  @spec text_regular(map()) :: Phoenix.LiveView.Rendered.t()
  @doc """
  Renders a text regular.
  """
  attr :text, :string, required: true
  attr :class, :string, default: "text-2xl font-bold"

  def text_regular(assigns) do
    ~H"""
    <span class={@class}> <%= @text %> </span>
    """
  end

  @doc """
  Renders a subheader.
  """
  attr :text, :string, required: true
  attr :class, :string, default: "text-xl text-gray-400"

  def text_subheader(assigns) do
    ~H"""
    <h3 class={@class}> <%= @text %> </h3>
    """
  end

  @doc """
  Renders a dynamic icon button using Heroicons.
  """
  attr :phx_click, :string
  attr :icon_name, :atom, required: true  # The name of the Heroicon (e.g., :archive)
  attr :button_class, :string, default: "h-12 w-12 bg-gray-400"
  attr :icon_class, :string, default: "h-8 w-8 rounded-full"

  def icon_button(assigns) do
    heroicon_component = case assigns[:icon_style] do
      :solid -> Heroicons.Solid
      _ -> Heroicons.Outline
    end

    ~H"""
    <button phx-click={@phx_click} class={@button_class}>
      <span class="sr-only">Icon button</span>
      <div class="bg-gray-200 rounded-full h-10 w-10 flex items-center justify-center">
        <%= heroicon_component.render(%{icon: @icon_name, class: @icon_class}) %>
      </div>
    </button>
    """
  end


  @doc """
  Renders a simple form.
  """
  # Include the attributes here
  attr :phx_change, :string
  attr :phx_submit, :string
  attr :phx_target, :string
  slot :inner_block, required: true
  slot :actions, required: true

  def simple_form(assigns) do
    ~H"""
    <form phx-change={@phx_change} phx-submit={@phx_submit} phx-target={@phx_target}>
      <%= render_slot(@inner_block) %>
      <div class="form-actions">
        <%= render_slot(@actions) %>
      </div>
    </form>
    """
  end

  @doc """
  Renders an icon.
  """
  # Include the class attribute here
  attr :class, :string
  attr :name, :string, required: true

  def icon(assigns) do
    ~H"""
    <i class={@class}><%= @name %></i>
    """
  end

  # ...

  @doc """
  Renders a header.
  """
  # Include the class attribute here
  attr :class, :string, default: "default-class"
  slot :inner_block, required: true

  def header(assigns) do
    ~H"""
    <header class={@class}>
      <%= render_slot(@inner_block) %>
    </header>
    """
  end

  @doc """
  Renders an input with a label.
  """
  attr :phx_change, :string
  attr :field, :any, required: true
  attr :type, :string, default: "text"

  def input(assigns) do
    ~H"""
    <label for={@field.id}>
      <%= @field.label %>
      <input type={@type} id={@field.id} value={@field.value} phx-change={@phx_change} />
    </label>
    """
  end

  attr :type, :string, default: nil
  attr :class, :string, default: "text-white bg-blue-600 hover:bg-blue-800 rounded p-3"
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def gbutton(assigns) do
    ~H"""
    <button
      type={@type}
      class={@class}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr :title, :string, required: true
  attr :class, :string, default: "flex flex-col gap-3 p-3"
  slot :inner_block
  def container(assigns) do
    ~H"""
    <div class={@class}>
      <span> <%= @title %> </span>
        <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders an avatar icon with initials and a random pastel background color.
  """
  attr :initials, :string, required: true
  attr :class, :string, default: "h-10 w-10 pt-1 bg-blue-500 flex items-center justify-center rounded-full text-white text-lg font-semibold"

  def avatar_icon(assigns) do
    ~H"""
    <div class={@class}>
      <span><%= @initials %></span>
    </div>
    """
  end

  @doc """
  Renders an input with an optional Feather icon.
  """
  attr :phx_change, :string
  attr :type, :string, default: "text"
  attr :placeholder, :string, default: ""
  attr :icon, :string, default: "search" # Feather icon name
  attr :input_class, :string, default: "rounded-full pl-12 pr-4 h-12 w-full focus:ring-2 focus:ring-blue-300 outline-none text-xl"
  attr :input_container_class, :string, default: "flex items-center border rounded-full"

  def input_with_icon(assigns) do
    ~H"""
    <div class={@input_container_class}>
      <div class="absolute ml-4">
        <Heroicons.Outline.search class="h-7 w-7 text-gray-300" />
      </div>
      <input
        type={@type}
        placeholder={@placeholder}
        class={@input_class}
        phx-change={@phx_change}
      />
    </div>
    """
  end

  @doc """
  Renders an outline button with a Feather icon.
  """
  attr :text, :string, required: true
  attr :icon, :string, required: true # Feather icon name
  attr :phx_click, :string
  attr :button_class, :string, default: "group flex items-center border border-gray-200 h-12 px-4 pr-16 rounded-full text-lg hover:bg-blue-400 focus:outline-none flex items-center justify-center"

  def outline_button_with_icon(assigns) do
    ~H"""
    <button class={@button_class} phx-click={@phx_click}>
      <Heroicons.Outline.users class="h-6 w-6 mr-2 text-gray-300" />
      <span class="text-gray-400 group-hover:text-white"><%= @text %></span>
    </button>
    """
  end

  @doc """
  Renders a container for cards.
  """
  slot :card_content

  def card_container(assigns) do
    ~H"""
    <div class="list-container p-4 rounded-2xl overflow-hidden min-w-10">
      <%= render_slot(@card_content) %>
    </div>
    """
  end

  @doc """
  Renders an individual card.
  """
  attr :title, :string
  attr :description, :string
  attr :image_url, :string, default: nil # Optional image
  attr :tags, :list, default: [] # Optional list of tags
  # ... additional attributes for the card ...

  def card(assigns) do
    ~H"""
    <div class="bg-white rounded-2xl py-6 px-4 border-b last:border-b-0 shadow-sm">
      <h3 class="text-2xl font-bold"><%= @title %></h3>
      <p class="text-xl text-gray-400"><%= @description %></p>
      <div class="flex space-x-2 mt-5">
        <%= for tag <- @tags do %>
          <span class="bg-blue-100 text-blue-800 text-base font-semibold mr-2 px-2.5 py-1 rounded-full dark:bg-blue-200 dark:text-blue-800"><%= tag %></span>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a textarea component.
  """
  attr :phx_change, :string
  attr :placeholder, :string, default: "Enter a title for your card..."
  attr :rows, :integer, default: 3
  attr :class, :string, default: "bg-gray-100 block w-auto text-xl rounded-2xl p-4 text-gray-700"

  def textarea(assigns) do
    ~H"""
    <textarea
      placeholder={@placeholder}
      rows={@rows}
      class={@class}
      phx-change={@phx_change}>
    </textarea>
    """
  end

  @doc """
  Renders a simple button.
  """
  attr :phx_click, :string
  attr :text, :string, default: "Add task"
  attr :class, :string, default: "px-4 py-2 bg-blue-500 w-40 text-white font-semibold text-xl rounded-xl shadow-md hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-300 tracking-normal"

  def button(assigns) do
    ~H"""
    <button
      phx-click={@phx_click}
      class={@class}>
      <%= @text %>
    </button>
    """
  end
end
