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
        send(liveview_pid, {:tasks_fetched, tasks})
      {:error, _reason} ->
        IO.puts("fetch task error")
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Tasks List</h1>
    <ul>
      <%= for task <- @tasks do %>
        <li>
          <%= if Enum.at(@tasks, 0)["id"] != task["id"] do %>
            <button phx-click="move-up" phx-value-id={task["id"]}>Move up</button>
          <% end %>

          <%= if Enum.at(@tasks, Enum.count(@tasks) - 1)["id"] != task["id"] do %>
            <button phx-click="move-down" phx-value-id={task["id"]}>Move down</button>
          <% end %>
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
    case Enum.find(socket.assigns.tasks, fn %{"id" => task_id} = _task -> task_id == id; _ -> false end) do
      nil ->
        IO.puts("Task not found in assigns for ID #{id}")
        {:noreply, socket}
      %{"completed" => completed} ->
        new_completed_value = not(completed)
        task_params = %{"completed" => new_completed_value}

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

  def handle_event("move-up", %{"id" => id}, socket) do
    IO.puts("MOVE UP")
    id = String.to_integer(id)
    move_task(socket, id, :up)
  end

  # Handle event to move a task down
  def handle_event("move-down", %{"id" => id}, socket) do
    id = String.to_integer(id)
    move_task(socket, id, :down)
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

  defp move_task(socket, id, direction) do
    current_tasks = socket.assigns.tasks
    case find_task_index(current_tasks, id) do
      {:ok, index} ->
        {_new_tasks, swapped_tasks} = swap_tasks(current_tasks, index, direction)
        IO.inspect(swapped_tasks, label: "swapped_tasks")
        unless Enum.empty?(swapped_tasks) do
          update_task_ranks(socket, swapped_tasks)
          fetch_and_refresh_tasks(socket)
        end
        {:noreply, socket}
      :error -> {:noreply, socket}
    end
  end

  # Find the index of a task by ID
  defp find_task_index(tasks, id) do
    Enum.find_index(tasks, fn task -> task["id"] == id end)
    |> case do
      nil -> :error
      index -> {:ok, index}
    end
  end


  defp swap_tasks(tasks, index, direction) do
    # Determine the index of the task to swap with
    swap_index = case direction do
      :up -> index - 1
      :down -> index + 1
    end

    # Ensure swap is within bounds
    if swap_index in 0..(length(tasks) - 1) do
      task1 = Enum.at(tasks, index)
      task2 = Enum.at(tasks, swap_index)

      IO.inspect(task1, label: "task_1")
      IO.inspect(task2, label: "task_2")
      # Swap task ranks if both tasks exist and have a rank
      if task1 && task2 && task1["rank"] && task2["rank"] do
        task1_rank = task1["rank"]
        task1 = Map.put(task1, "rank", task2["rank"])
        task2 = Map.put(task2, "rank", task1_rank)

        # Update the tasks list
        tasks = List.replace_at(tasks, index, task1)
        tasks = List.replace_at(tasks, swap_index, task2)

        IO.inspect(tasks, label: "SWAP_TASKS")
        {tasks, [task1, task2]}
      else
        IO.puts("Cannot swap: One or both tasks do not have a rank.")
        {tasks, []}
      end
    else
      IO.puts("Cannot swap: Task is at the boundary.")
      {tasks, []}
    end
  end

  defp update_task_ranks(socket, swapped_tasks) do
    access_token = socket.assigns.access_token
    liveview_pid = self()

    Enum.each(swapped_tasks, fn task ->
      IO.puts("Updating task #{task["id"]} with new rank #{task["rank"]}")
      case TaskClient.update_user_task(access_token, task["id"], %{"rank" => task["rank"]}) do
        {:ok, response} ->
          IO.inspect(response, label: "Update Response")
        {:error, reason} ->
          IO.inspect(reason, label: "Update Error")
          # Here you may want to handle the error, e.g., by sending a message to the LiveView or logging
      end
    end)

    # Send a message to self to trigger a refetch of tasks
    send(liveview_pid, :refetch_tasks)
  end
end
