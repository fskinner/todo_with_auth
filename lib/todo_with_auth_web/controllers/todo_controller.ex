defmodule TodoWithAuthWeb.TodoController do
  use TodoWithAuthWeb, :controller

  alias TodoWithAuth.Main
  alias TodoWithAuth.Main.Todo

  action_fallback TodoWithAuthWeb.FallbackController

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)

    todos = Main.list_todos(current_user.id)
    render(conn, "index.json", todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    params = todo_params
            |> Enum.into(%{"user_id" => current_user.id})

    with {:ok, %Todo{} = todo} <- Main.create_todo(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", todo_path(conn, :show, todo))
      |> render("show.json", todo: todo)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    
    todo = Main.get_todo!(id)
    if todo.user_id == current_user.id do
      render(conn, "show.json", todo: todo)
    else
      conn |> unauthorized
    end
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Main.get_todo!(id)
    current_user = Guardian.Plug.current_resource(conn)

    if todo.user_id == current_user.id do
      params = todo_params
      |> Enum.into(%{"user_id" => current_user.id})

      with {:ok, %Todo{} = todo} <- Main.update_todo(todo, params) do
        render(conn, "show.json", todo: todo)
      end
    else
      conn |> unauthorized
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Main.get_todo!(id)
    current_user = Guardian.Plug.current_resource(conn)

    if todo.user_id == current_user.id do
      with {:ok, %Todo{}} <- Main.delete_todo(todo) do
        send_resp(conn, :no_content, "")
      end
    else
      conn |> unauthorized
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(401)
    |> render(TodoWithAuthWeb.ErrorView, "401.json")
  end
end
