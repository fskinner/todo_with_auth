defmodule TodoWithAuthWeb.TodoView do
  use TodoWithAuthWeb, :view
  alias TodoWithAuthWeb.TodoView

  def render("index.json", %{todos: todos}) do
    %{data: render_many(todos, TodoView, "todo.json")}
  end

  def render("show.json", %{todo: todo}) do
    %{data: render_one(todo, TodoView, "todo.json")}
  end

  def render("todo.json", %{todo: todo}) do
    %{id: todo.id, description: todo.description, complete: todo.complete, user_id: todo.user_id}
  end
end
