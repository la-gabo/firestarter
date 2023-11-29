defmodule FirestarterWeb.CoreComponents do
  use Phoenix.Component

  # ...

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

  # ...

  @doc """
  Renders a button.
  """
  # Include the class attribute here
  attr :phx_click, :string
  attr :class, :string
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button class={@class} phx-click={@phx_click}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  # ...

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

end
