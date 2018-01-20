defmodule TodoWithAuthWeb.TodoController do
  use TodoWithAuthWeb, :controller
  use TodoWithAuthWeb.BaseController

  alias TodoWithAuth.Todos
  alias TodoWithAuth.Todos.Todo

  action_fallback(TodoWithAuthWeb.FallbackController)

  def index(conn, _params, current_user) do
    todos = Todos.list_todos(current_user.id)
    render(conn, "index.json", todos: todos)
  end

  def create(conn, %{"todo" => todo_params}, current_user) do
    params =
      todo_params
      |> Enum.into(%{"user_id" => current_user.id})

    with {:ok, %Todo{} = todo} <- Todos.create_todo(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", todo_path(conn, :show, todo))
      |> render("show.json", todo: todo)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    todo = Todos.get_todo!(id)

    with {:ok} <- check_ownership(todo, current_user) do
      render(conn, "show.json", todo: todo)
    else
      _ ->
        conn |> unauthorized
    end
  end

  def update(conn, %{"id" => id, "todo" => todo_params}, current_user) do
    todo = Todos.get_todo!(id)

    if todo.user_id == current_user.id do
      params =
        todo_params
        |> Enum.into(%{"user_id" => current_user.id})

      with {:ok, %Todo{} = todo} <- Todos.update_todo(todo, params) do
        render(conn, "show.json", todo: todo)
      end
    else
      conn |> unauthorized
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    todo = Todos.get_todo!(id)

    with {:ok} <- check_ownership(todo, current_user),
         {:ok, %Todo{}} <- Todos.delete_todo(todo) do
      send_resp(conn, :no_content, "")
    else
      _ ->
        conn |> unauthorized
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(401)
    |> render(TodoWithAuthWeb.ErrorView, "401.json")
  end

  defp check_ownership(todo, current_user) do
    if todo.user_id == current_user.id do
      {:ok}
    else
      {:error}
    end
  end
end
