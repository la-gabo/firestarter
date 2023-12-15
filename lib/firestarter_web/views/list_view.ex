defmodule FirestarterWeb.ListView do
  use FirestarterWeb, :view
  alias FirestarterWeb.ListView

  def render("index.json", %{lists: lists}) do
    %{data: render_many(lists, ListView, "list.json")}
  end

  def render("show.json", %{list: list}) do
    %{data: render_one(list, ListView, "list.json")}
  end

  def render("list.json", %{list: list}) do
    %{
      id: list.id,
      title: list.title,
      rank: list.rank,
      user_id: list.user_id
    }
  end
end
