defmodule TodoWithAuthWeb.TodoViewTest do
  use TodoWithAuthWeb.ConnCase, async: true

  import TodoWithAuth.Factory
  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  alias TodoWithAuthWeb.TodoView

  defp todo_json(todo) do
    %{id: todo.id, description: todo.description, complete: todo.complete, user_id: todo.user_id}
  end

  test "renders todo.json" do
    todo = insert(:todo)
    rendered_todo = render(TodoView, "todo.json", todo: todo)

    assert rendered_todo == todo_json(todo)
  end

  test "renders index.json" do
    todo = insert(:todo)
    rendered_todo = render(TodoView, "index.json", %{todos: [todo]})

    assert rendered_todo == %{data: [todo_json(todo)]}
  end

  test "renders show.json" do
    todo = insert(:todo)
    rendered_todo = render(TodoView, "show.json", %{todo: todo})

    assert rendered_todo == %{data: todo_json(todo)}
  end
end
