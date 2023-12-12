defmodule FirestarterWeb.TasksLive do
  use FirestarterWeb, :live_view
  alias Firestarter.TaskClient
  alias FirestarterWeb.CoreComponents, as: FUI

  def mount(_params, session, socket) do
    liveview_pid = self()
    socket = assign_initial_state(socket, session)

    if access_token = socket.assigns.access_token do
      Task.start(fn -> fetch_tasks(access_token, liveview_pid) end)
    end

    {:ok, socket}
  end

  def handle_info({:tasks_fetched, tasks}, socket) do
    {:noreply, assign(socket, tasks: tasks)}
  end


  defp fetch_tasks(access_token, liveview_pid) do
    case TaskClient.fetch_user_tasks(access_token) do
      {:ok, response} -> send(liveview_pid, {:tasks_fetched, response.body["data"]})
      {:error, _reason} -> IO.puts("fetch task error")
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Header Section -->
      <div class="flex flex-col justify-between">
        <div class="flex gap-5">
          <FUI.text_header text="Daily Organizer" />
          <div class="flex gap-2">
            <FUI.avatar_icon initials="SF" />
            <FUI.avatar_icon initials="GO" />
          </div>
        </div>
        <div class="mt-4">
          <FUI.text_subheader text="Daily Organizer" />
        </div>
        <!-- Other header components like user info and icons -->
      </div>

      <!-- Search and Action Section -->
      <div class="flex justify-between items-center">
        <FUI.input_with_icon phx_change="search" placeholder="Search..." icon="search-icon-class" />
      </div>

      <!-- Main Content Area -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <!-- Due Soon List -->
        <FUI.card_container>
          <:card_content>
            <!-- Individual cards will be placed here -->
            <!-- Example content for the slot -->
            <div class="p-5">
             <FUI.card title="Example Task" description="This is an example task." tags={["Design", "Urgent"]} />
            </div>
          </:card_content>
        </FUI.card_container>

        <!-- In Progress List -->
        <%!-- <FUI.card_container>
          <.slot name="card_content">
            <!-- Individual cards will be placed here -->
              <h1>Hello</h1>
          </.slot>
        </FUI.card_container> --%>

        <!-- Done List -->
        <%!-- <FUI.card_container>
          <.slot name="card_content">
            <!-- Individual cards will be placed here -->
            <h1>Hello</h1>
          </.slot>
        </FUI.card_container> --%>
      </div>
    </div>
    """
  end

  def handle_event("add-task", %{"new_task_title" => title}, socket) do
    case TaskClient.create_user_task(socket.assigns.access_token, %{title: title}) do
      {:ok, _response} ->
        socket = fetch_and_refresh_tasks(socket)
        {:noreply, put_flash(socket, :info, "Task added successfully")}
      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Error adding task")}
    end
  end

  def handle_event("toggle-completed", %{"id" => id}, socket) do
    id = String.to_integer(id)
    find_and_toggle_task(id, socket)
  end

  def handle_event("delete-task", %{"id" => id}, socket) do
    case TaskClient.delete_user_task(socket.assigns.access_token, id) do
      {:ok, _response} ->
        socket = fetch_and_refresh_tasks(socket)
        {:noreply, put_flash(socket, :info, "Task deleted successfully")}
      {:error, _reason} ->
        {:noreply, log_error("Error deleting task", socket)}
    end
  end

  def handle_event("show-form", _params, socket) do
    {:noreply, toggle_show_form(socket)}
  end

  def handle_event("move-up", %{"id" => id}, socket) do
    move_task(socket, String.to_integer(id), :up)
  end

  def handle_event("move-down", %{"id" => id}, socket) do
    move_task(socket, String.to_integer(id), :down)
  end

  def handle_event("reposition", %{"id" => id, "new" => new_index, "old" => old_index}, socket) do
    handle_reposition_event(String.to_integer(id), new_index, old_index, socket)
  end

  defp assign_initial_state(socket, session) do
    assign(socket, access_token: session["access_token"], tasks: [], new_task_title: "", show_form: false, editing_task_id: nil)
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

  defp handle_reposition_event(id, new_index, old_index, socket) do
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

      case Firestarter.Tasks.reorder_task(id, above_id, below_id) do
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
