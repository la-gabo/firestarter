defmodule FirestarterWeb.UsersLive do
  use FirestarterWeb, :live_view
  alias Firestarter.AccountClient
  alias FirestarterWeb.CoreComponents, as: FUI

  def mount(_params, %{"access_token" => access_token} = session, socket) do
    socket = assign(socket, :access_token, access_token)

    users = fetch_users(access_token) # Synchronous call to get users list
    socket = assign(socket, :users, users)

    {:ok, socket}
  end

  def handle_info({:users_fetched, users}, socket) do
    {:noreply, assign(socket, users: users)}
  end

  def handle_event("change-permission", %{"selected_permission" => new_permission, "user_id" => user_id} = params, socket) do
    access_token = socket.assigns.access_token

    # Convert "new_permission" and "user_id" to integers
    new_permission = String.to_integer(new_permission)

    AccountClient.update_user(access_token, user_id, %{user: %{permission_id: new_permission}})

    users = fetch_users(access_token)
    {:noreply, assign(socket, :users, users)}
  end

  defp fetch_users(access_token) do
    case AccountClient.fetch_all_users(access_token) do
      {:ok, response} ->
        response.body["data"]
      {:error, _reason} ->
        IO.puts("fetch users error")
        []
    end
  end

  defp assign_initial_state(socket, session) do
    assign(
      socket,
      access_token: session["access_token"],
      users: []
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <FUI.text_header text="User Permissions" />
      <div class="mt-10">
        <%= for user <- @users do %>
          <form class="flex gap-5 items-center" phx-change="change-permission">
          <FUI.text_subheader text={user["email"]} />
            <div style="width: 100px">
              <input name="user_id" value={Integer.to_string(user["id"])} hidden />
              <FUI.select
                field={%{id: "user_permission_#{user["id"]}", name: "selected_permission", label: ""}}
                options={get_permission_options(user["permission_id"])}
                phx_value_user_id={Integer.to_string(user["id"])}
              />
            </div>
          </form>
        <% end %>
      </div>
    </div>
    """
  end

  defp get_permission_options(current_permission_id) do
    options = [
      {"1", "Manage"},
      {"2", "Write"},
      {"3", "Read"}
    ]

    Enum.map(options, fn {value, text} ->
      selected = Integer.to_string(current_permission_id) == value
      {value, text, selected: selected}
    end)
  end
end
