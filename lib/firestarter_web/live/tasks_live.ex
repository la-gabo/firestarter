defmodule FirestarterWeb.TasksLive do
  use FirestarterWeb, :live_view
  alias Firestarter.TaskClient

  def mount(_params, session, socket) do
    liveview_pid = self() # Capture the LiveView's PID
    socket = assign(socket, access_token: session["access_token"], tasks: [], new_task_title: "", show_form: false, editing_task_id: nil)

    if access_token = socket.assigns.access_token do
      # Start the task and pass the LiveView's PID
      Task.start(fn -> fetch_tasks(access_token, liveview_pid) end)
    end

    {:ok, socket}
  end

  def handle_info({:tasks_fetched, tasks}, socket) do
    {:noreply, assign(socket, tasks: tasks)}
  end

  defp fetch_tasks(access_token, liveview_pid) do
    case TaskClient.fetch_user_tasks(access_token) do
      {:ok, response} ->
        tasks = response.body["data"]
        # Send the message back to the LiveView's process using the captured PID
        send(liveview_pid, {:tasks_fetched, tasks})
      {:error, _reason} ->
        IO.puts("fetch task error")
        # Handle error
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Tasks List</h1>
    <ul>
      <%= for task <- @tasks do %>
        <li>
          <%= if @editing_task_id do %>
          <form phx-submit="save-task" phx-value-id={task["id"]}>
            <input type="text" name="task_title" value={task["title"]} />
            <button type="submit">Save</button>
          </form>
          <% else %>
            <%= task["title"] %> - <%= if task["completed"], do: "Completed", else: "Pending" %>
            <%!-- <button phx-click="edit-task" phx-value-id={task["id"]}>Edit</button> --%>
          <% end %>
          <button phx-click="delete-task" phx-value-id={task["id"]}>Delete</button>
          <button phx-click="toggle-completed" phx-value-id={task["id"]}>Toggle</button>
        </li>
      <% end %>
    </ul>

    <%= if @show_form do %>
      <form phx-submit="add-task">
        <input type="text" name="new_task_title" value={@new_task_title} />
        <button type="submit">Add Task</button>
      </form>
    <% else %>
      <button phx-click="show-form">Add Task</button>
    <% end %>
    """
  end

   # Handle event to add a task
   def handle_event("add-task", %{"new_task_title" => title}, socket) do
    case TaskClient.create_user_task(socket.assigns.access_token, %{title: title}) do
      {:ok, _response} ->
        fetch_and_refresh_tasks(socket)
      {:error, _reason} ->
        IO.puts("Error creating task")
        {:noreply, socket}
    end
  end

  # Handle event to update a task
  def handle_event("update-task", %{"id" => id, "task_params" => task_params}, socket) do
    case TaskClient.update_user_task(socket.assigns.access_token, id, task_params) do
      {:ok, _response} ->
        fetch_and_refresh_tasks(socket)
      {:error, _reason} ->
        IO.puts("Error updating task")
    end
    {:noreply, socket}
  end

  def handle_event("toggle-completed", %{"id" => id}, socket) do
    id = String.to_integer(id) # Convert the id to an integer

    # Find the task by ID in the socket assigns
    case Enum.find(socket.assigns.tasks, fn %{"id" => task_id} = task -> task_id == id; _ -> false end) do
      nil ->
        IO.puts("Task not found in assigns for ID #{id}")
        {:noreply, socket}
      %{"completed" => completed} ->
        new_completed_value = not(completed)
        task_params = %{"completed" => new_completed_value}

        IO.puts("Updating task with ID #{id} to completed: #{new_completed_value}")

        case TaskClient.update_user_task(socket.assigns.access_token, id, task_params) do
          {:ok, _response} ->
            fetch_and_refresh_tasks(socket)
          {:error, _reason} ->
            IO.puts("Error updating task")
            {:noreply, socket}
        end
    end
  end

  # Handle event to delete a task
  def handle_event("delete-task", %{"id" => id}, socket) do
    case TaskClient.delete_user_task(socket.assigns.access_token, id) do
      {:ok, _response} ->
        # Call fetch_and_refresh_tasks and use the updated socket it returns
        fetch_and_refresh_tasks(socket)
      {:error, _reason} ->
        IO.puts("Error deleting task")
        {:noreply, socket}
    end
  end

  def handle_event("show-form", _params, socket) do
    # Toggle the form visibility
    new_show_form_state = !socket.assigns.show_form
    {:noreply, assign(socket, show_form: new_show_form_state)}
  end

  # Helper function to fetch tasks and refresh the LiveView
  defp fetch_and_refresh_tasks(socket) do
    case TaskClient.fetch_user_tasks(socket.assigns.access_token) do
      {:ok, response} ->
        tasks = response.body["data"]
        # Update the socket with the new tasks
        socket = assign(socket, tasks: tasks)
        {:noreply, socket}
      {:error, _reason} ->
        IO.puts("Error fetching tasks")
        {:noreply, socket}
    end
  end
end
