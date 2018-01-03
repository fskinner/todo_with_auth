defmodule TodoWithAuthWeb.TodoControllerTest do
  use TodoWithAuthWeb.ConnCase

  import TodoWithAuth.Factory

  alias TodoWithAuth.Todos
  alias TodoWithAuth.Todos.Todo
  alias TodoWithAuth.Authentication

  @create_attrs %{complete: true, description: "some description"}
  @update_attrs %{complete: false, description: "some updated description"}
  @invalid_attrs %{complete: nil, description: nil}
  @user_attrs %{email: "email1@mail.com", password: "some password"}

  def fixture(:todo, user) do
    attrs = @create_attrs
          |> Enum.into(%{user_id: user.id})

    {:ok, todo} = Todos.create_todo(attrs)
    todo
  end

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  describe "index/1" do
    setup context do
      {_, user} = create_user(context)
      user =
        user
        |> List.first
        |> elem(1)

      {_, todo} = create_todo(context, user)
      todo =
        todo
        |> List.first
        |> elem(1)

      {:ok, todo: todo, user: user}
    end

    test "lists all todos", %{conn: conn, user: user} do
      response =
        conn
        |> authenticate_user(user)
        |> get(todo_path(conn, :index))
        |> json_response(200)

      todo = response["data"] |> List.first

      assert todo["complete"] == true
      assert todo["description"] == "some description"
      assert todo["user_id"] == user.id
      assert todo["id"] != nil
    end
  end

  describe "show/2" do
    setup context do
      {_, user} = create_user(context)
      user =
        user
        |> List.first
        |> elem(1)

      {_, todo} = create_todo(context, user)
      todo =
        todo
        |> List.first
        |> elem(1)

      {:ok, todo: todo, user: user}
    end

    test "renders todo", %{conn: conn, todo: %Todo{id: id} = todo, user: user} do
      response =
        conn
        |> authenticate_user(user)
        |> get(todo_path(conn, :show, todo))
        |> json_response(200)

      returned_todo = response["data"]

      assert returned_todo["complete"] == todo.complete
      assert returned_todo["description"] == todo.description
      assert returned_todo["user_id"] == user.id
      assert returned_todo["id"] == id
    end

    test "renders 404 when no todo is found", %{conn: conn, user: user} do
      conn = conn |> authenticate_user(user)
      assert_error_sent 404, fn ->
        delete conn, todo_path(conn, :show, -1)
      end
    end

    test "renders 401 when user is not todo owner", %{conn: conn, todo: todo} do
      other_user = insert(:user)

      response =
        conn
        |> authenticate_user(other_user)
        |> get(todo_path(conn, :update, todo))
        |> json_response(401)

      assert response["errors"] == %{"detail" => "Unauthorized"}
    end
  end

  describe "create/2" do
    setup [:create_user]
    
    test "renders todo when data is valid", %{conn: conn, user: user} do
      response =
        conn
        |> authenticate_user(user)
        |> post(todo_path(conn, :create), todo: @create_attrs)
        |> json_response(201)

      new_todo = response["data"]

      assert new_todo["complete"] == true
      assert new_todo["description"] == "some description"
      assert new_todo["user_id"] == user.id
      assert new_todo["id"] != nil
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      response =
        conn
        |> authenticate_user(user)
        |> post(todo_path(conn, :create), todo: @invalid_attrs)
        |> json_response(422)

      assert response["errors"] != %{}
    end
  end

  describe "update/2" do
    setup context do
      {_, user} = create_user(context)
      user =
        user
        |> List.first
        |> elem(1)

      {_, todo} = create_todo(context, user)
      todo =
        todo
        |> List.first
        |> elem(1)

      {:ok, todo: todo, user: user}
    end

    test "renders todo when data is valid", %{conn: conn, todo: %Todo{id: id} = todo, user: user} do
      response =
        conn
        |> authenticate_user(user)
        |> put(todo_path(conn, :update, todo), todo: @update_attrs)
        |> json_response(200)

      updated_todo = response["data"]

      assert updated_todo["complete"] == false
      assert updated_todo["description"] == "some updated description"
      assert updated_todo["user_id"] == user.id
      assert updated_todo["id"] == id
    end

    test "renders errors when data is invalid", %{conn: conn, todo: todo, user: user} do
      response =
        conn
        |> authenticate_user(user)
        |> put(todo_path(conn, :update, todo), todo: @invalid_attrs)
        |> json_response(422)

      assert response["errors"] != %{}
    end

    test "renders 404 when no todo is found", %{conn: conn, user: user} do
      conn = conn |> authenticate_user(user)
      assert_error_sent 404, fn ->
        put conn, todo_path(conn, :update, -1), todo: @update_attrs
      end
    end

    test "renders 401 when user is not todo owner", %{conn: conn, todo: todo} do
      other_user = insert(:user)

      response =
        conn
        |> authenticate_user(other_user)
        |> put(todo_path(conn, :update, todo), todo: @update_attrs)
        |> json_response(401)

      assert response["errors"] == %{"detail" => "Unauthorized"}
    end
  end

  describe "delete/2" do
    setup context do
      {_, user} = create_user(context)
      user =
        user
        |> List.first
        |> elem(1)

      {_, todo} = create_todo(context, user)
      todo =
        todo
        |> List.first
        |> elem(1)

      {:ok, todo: todo, user: user}
    end

    test "deletes chosen todo", %{conn: conn, todo: todo, user: user} do
      conn =
        conn
        |> authenticate_user(user)
        |> delete(todo_path(conn, :delete, todo))

      assert response(conn, 204)
    end

    test "renders 404 when no todo is found", %{conn: conn, user: user} do
      conn = conn |> authenticate_user(user)
      assert_error_sent 404, fn ->
        delete conn, todo_path(conn, :delete, -1)
      end
    end

    test "renders 401 when user is not todo owner", %{conn: conn, todo: todo} do
      other_user = insert(:user)

      response =
        conn
        |> authenticate_user(other_user)
        |> delete(todo_path(conn, :delete, todo))
        |> json_response(401)

      assert response["errors"] == %{"detail" => "Unauthorized"}
    end
  end

  defp authenticate_user(conn, user) do
    {:ok, token, _claims} = TodoWithAuthWeb.Guardian.encode_and_sign(user)
    conn |> put_req_header("authorization", "Bearer #{token}")
  end

  defp create_user(_context) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp create_todo(_context, user) do
    todo = fixture(:todo, user)
    {:ok, todo: todo}
  end
  
end
