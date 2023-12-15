defmodule FirestarterWeb.TasksLive do
  use FirestarterWeb, :live_view
  alias Firestarter.TaskClient
  alias Firestarter.ListClient
  alias FirestarterWeb.CoreComponents, as: FUI

  def mount(_params, session, socket) do
    liveview_pid = self()
    socket = assign_initial_state(socket, session)

    if access_token = socket.assigns.access_token do
      Task.start(fn -> fetch_tasks(access_token, liveview_pid) end)
      Task.start(fn -> fetch_lists(access_token, liveview_pid) end)
    end

    {:ok, socket}
  end

  def handle_info({:tasks_fetched, tasks}, socket) do
    {:noreply, assign(socket, tasks: tasks)}
  end

  def handle_info({:lists_fetched, lists}, socket) do
    {:noreply, assign(socket, lists: lists)}
  end

  defp fetch_tasks(access_token, liveview_pid) do
    case TaskClient.fetch_user_tasks(access_token) do
      {:ok, response} ->
          send(liveview_pid, {:tasks_fetched, response.body["data"]})
      {:error, _reason} -> IO.puts("fetch task error")
    end
  end

  defp fetch_lists(access_token, liveview_pid) do
    case ListClient.fetch_user_lists(access_token) do
      {:ok, response} ->
        send(liveview_pid, {:lists_fetched, response.body["data"]})
      {:error, _reason} -> IO.puts("fetch lists error")
    end
  end

  def handle_event("add-task", params, socket) do
    %{"new_task_title" => title, "list_id" => id} = params
    case TaskClient.create_user_task(socket.assigns.access_token, %{title: title, list_id: id}) do
      {:ok, response} ->
        socket = fetch_and_refresh_tasks(socket)
        socket = assign(socket, :active_card_id, nil) # Reset active_card_id
        {:noreply, put_flash(socket, :info, "Task added successfully")}
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Error adding task")}
    end
  end

  def handle_event("add-list", %{"new_list_title" => title}, socket) do
    access_token = socket.assigns.access_token
    list_params = %{title: title}

    case ListClient.create_user_list(access_token, list_params) do
      {:ok, _response} ->
        # Fetch updated lists after adding a new one
        case ListClient.fetch_user_lists(access_token) do
          {:ok, updated_response} ->
            # Update the lists in the socket's assigns
            updated_lists = updated_response.body["data"]
            socket = assign(socket, lists: updated_lists)
            {:noreply, put_flash(socket, :info, "List added successfully")}

          {:error, fetch_error} ->
            # Handle error in fetching updated lists
            IO.puts("Error fetching updated lists: #{inspect(fetch_error)}")
            {:noreply, put_flash(socket, :error, "Error fetching updated lists")}
        end

      {:error, reason} ->
        # Handle error in creating a new list
        IO.puts("Error creating list: #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Error creating list")}
    end
  end

  def handle_event("handle_new_task_title", %{"value" => new_task_title}, socket) do
    {:noreply, assign(socket, :new_task_title, new_task_title)}
  end

  def handle_event("toggle-completed", %{"id" => id}, socket) do
    id = String.to_integer(id)
    find_and_toggle_task(id, socket)
  end

  def handle_event("delete-task", %{"id" => id}, socket) do
    case TaskClient.delete_user_task(socket.assigns.access_token, id) do
      {:ok, _response} ->
        socket = fetch_and_refresh_tasks(socket)
        socket = assign(socket, :active_card_id, nil) # Reset active_card_id
        {:noreply, put_flash(socket, :info, "Task deleted successfully")}
      {:error, _reason} ->
        {:noreply, log_error("Error deleting task", socket)}
    end
  end

  def handle_event("show-form", _params, socket) do
    {:noreply, toggle_show_form(socket)}
  end

  def handle_event("show-people", _params, socket) do
    {:noreply, toggle_show_people(socket)}
  end

  def handle_event("show-labels", _params, socket) do
    {:noreply, toggle_show_labels(socket)}
  end

  def handle_event("show-task-control", %{"id" => id}, socket) do
    {:noreply, toggle_show_task_control(socket, id)}
  end

  def handle_event("move-up", %{"id" => id}, socket) do
    move_task(socket, String.to_integer(id), :up)
  end

  def handle_event("move-down", %{"id" => id}, socket) do
    move_task(socket, String.to_integer(id), :down)
  end

  def handle_event("reposition", params, socket) do
    %{"id" => id, "new" => new_index, "old" => old_index, "list_id" => list_id} = params
    IO.inspect(list_id, label: "++LIST_ID")
    handle_reposition_event(String.to_integer(id), new_index, old_index, String.to_integer(list_id), socket)
  end

  def handle_event("close-dropdown", _params, socket) do
    {:noreply, assign(socket, popover_people_show: false)}
  end

  defp assign_initial_state(socket, session) do
    assign(
      socket,
      access_token: session["access_token"],
      tasks: [],
      new_task_title: "",
      lists: [],
      show_form: false,
      editing_task_id: nil,
      ropdown_open: false,
      popover_people_show: false,
      popover_labels_show: false,
      assignees: [
        %{id: "checkbox1", value: "Maria Hiwaga", text: "Maria Hiwaga"},
        %{id: "checkbox2", value: "Jimmy Neutron", text: "Jimmy Neutron"},
        %{id: "checkbox2", value: "Jimmy Neutron", text: "Jimmy Neutron"},
        %{id: "checkbox2", value: "Jimmy Neutron", text: "Jimmy Neutron"},
        %{id: "checkbox2", value: "Jimmy Neutron", text: "Jimmy Neutron"},
        %{id: "checkbox1", value: "Maria Hiwaga", text: "Maria Hiwaga"},
        %{id: "checkbox1", value: "Maria Hiwaga", text: "Maria Hiwaga"},
        %{id: "checkbox1", value: "Maria Hiwaga", text: "Maria Hiwaga"},
        %{id: "checkbox2", value: "Jimmy Neutron", text: "Jimmy Neutron"},
      ],
      popover_task_control_show: false,
      active_card_id: 0,
      new_list_title: nil
    )
  end

  defp log_error(error_msg, socket) do
    IO.puts(error_msg)
    {:noreply, socket}
  end

  defp find_and_toggle_task(id, socket) do
    case Enum.find(socket.assigns.tasks, &(&1["id"] == id)) do
      nil -> {:noreply, log_error("Task not found in assigns for ID #{id}", socket)}
      task -> toggle_task_completion(task, socket)
    end
  end

  defp toggle_task_completion(task, socket) do
    new_completed_value = not task["completed"]
    task_params = Map.put(task, "completed", new_completed_value)

    case TaskClient.update_user_task(socket.assigns.access_token, task["id"], task_params) do
      {:ok, _response} ->
        socket = fetch_and_refresh_tasks(socket)
        {:noreply, put_flash(socket, :info, "Task updated successfully")}
      {:error, _reason} ->
        {:noreply, log_error("Error toggling task completion", socket)}
    end
  end

  defp toggle_show_form(socket) do
    assign(socket, show_form: not socket.assigns.show_form)
  end

  defp toggle_show_task_control(socket, id) do
    # Convert id to integer if it is a string that represents an integer
    id = case Integer.parse(id) do
      {parsed_id, ""} -> parsed_id
      _ -> id
    end

    # Check if the current active_card_id matches the clicked card's id
    current_id = socket.assigns.active_card_id
    new_active_id = if current_id == id, do: nil, else: id

    # Assign the new_active_id to the socket's assigns
    assign(socket, active_card_id: new_active_id)
  end

  defp toggle_show_people(socket) do
    if socket.assigns.popover_people_show do
      assign(socket, popover_people_show: false)
    else
      assign(socket, popover_people_show: true, popover_labels_show: false, dropdown_hook: "Dropdown")
    end
  end

  defp toggle_show_labels(socket) do
    if socket.assigns.popover_labels_show do
      assign(socket, popover_labels_show: false)
    else
      assign(socket, popover_labels_show: true, popover_people_show: false, dropdown_hook: "Dropdown")
    end
  end

  defp handle_reposition_event(id, new_index, old_index, list_id, socket) do
    tasks = socket.assigns.tasks

    # Check if the task is moved to an adjacent position
    if abs(new_index - old_index) == 1 do
      # For adjacent tasks, use move_task
      direction = if new_index < old_index, do: :up, else: :down
      move_task(socket, id, direction)
    else
      # For non-adjacent tasks, use reorder logic
      above_id = if new_index > 0, do: (tasks |> Enum.at(new_index - 1))["id"], else: nil
      below_id = if new_index < length(tasks) - 1, do: (tasks |> Enum.at(new_index + 1))["id"], else: nil

      case Firestarter.Tasks.reorder_task(id, above_id, below_id, list_id) do
        {:ok, _updated_task} ->
          socket = fetch_and_refresh_tasks(socket)
          {:noreply, put_flash(socket, :info, "Task ordered successfully")}
        {:error, _reason} ->
          {:noreply, log_error("Error reordering task", socket)}
      end
    end
  end

  defp fetch_and_refresh_tasks(socket) do
    case TaskClient.fetch_user_tasks(socket.assigns.access_token) do
      {:ok, response} ->
        tasks = response.body["data"]
        assign(socket, tasks: tasks)
      {:error, _reason} ->
        IO.puts("Error fetching tasks")
        socket
    end
  end

  defp move_task(socket, id, direction) do
    current_tasks = socket.assigns.tasks
    case find_task_index(current_tasks, id) do
      {:ok, index} ->
        {_updated_tasks, swapped_tasks} = swap_tasks(current_tasks, index, direction)
        update_task_ranks(socket, swapped_tasks)
        # The update_task_ranks function now handles the re-assignment of tasks
      :error ->
        {:noreply, socket}
    end
  end

  defp find_task_index(tasks, id) do
    Enum.find_index(tasks, fn task -> task["id"] == id end)
    |> case do
      nil -> :error
      index -> {:ok, index}
    end
  end

  defp swap_tasks(tasks, index, direction) do
    swap_index = case direction do
      :up -> index - 1
      :down -> index + 1
    end

    if swap_index in 0..(length(tasks) - 1) do
      task1 = Enum.at(tasks, index)
      task2 = Enum.at(tasks, swap_index)

      if task1 && task2 && task1["rank"] && task2["rank"] do
        task1_rank = task1["rank"]
        task1 = Map.put(task1, "rank", task2["rank"])
        task2 = Map.put(task2, "rank", task1_rank)
        tasks = List.replace_at(tasks, index, task1)
        tasks = List.replace_at(tasks, swap_index, task2)
        {Enum.sort_by(tasks, & &1["rank"]), [task1, task2]}
      else
        {tasks, []}
      end
    else
      {tasks, []}
    end
  end

  defp update_task_ranks(socket, swapped_tasks) do
    access_token = socket.assigns.access_token

    Enum.each(swapped_tasks, fn task ->
      TaskClient.update_user_task(access_token, task["id"], %{"rank" => task["rank"]})
    end)

    updated_tasks = update_task_ranks_local(socket.assigns.tasks, swapped_tasks)
    updated_sorted_tasks = Enum.sort_by(updated_tasks, & &1["rank"])
    {:noreply, socket |> assign(:tasks, updated_sorted_tasks)}
  end

  defp update_task_ranks_local(tasks, swapped_tasks) do
    Enum.map(tasks, fn task ->
      if swapped_task = Enum.find(swapped_tasks, &(&1["id"] == task["id"])), do: Map.put(task, "rank", swapped_task["rank"]), else: task
    end)
  end
end
