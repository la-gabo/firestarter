defmodule FirestarterWeb.TaskView do
  use FirestarterWeb, :view
  alias FirestarterWeb.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      title: task.title,
      completed: task.completed,
      rank: task.rank,
      list_id: task.list_id,
      assignee: render_assignee(task.assignee)
    }
  end

  defp render_assignee(nil), do: nil
  defp render_assignee(assignee) do
    %{
      id: assignee.id,
      email: assignee.email
    }
  end
end
