defmodule TodoWithAuth.TodosTest do
  use TodoWithAuth.DataCase

  alias TodoWithAuth.Todos
  alias TodoWithAuth.Authentication

  describe "todos" do
    alias TodoWithAuth.Todos.Todo

    @valid_attrs %{complete: true, description: "some description"}
    @update_attrs %{complete: false, description: "some updated description"}
    @invalid_attrs %{complete: nil, description: nil}

    @user_attrs %{email: "email@mail.com", password: "some password"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> Authentication.create_user()

      user
    end

    def todo_fixture(attrs \\ %{}) do
      {:ok, todo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Todos.create_todo()

      todo
    end

    test "list_todos/1 returns all todos from given user" do
      user = user_fixture()
      todo = todo_fixture(%{user_id: user.id})

      assert Todos.list_todos(user.id) == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      user = user_fixture()
      todo = todo_fixture(%{user_id: user.id})

      assert Todos.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      user = user_fixture()

      full_attrs = @valid_attrs |> Enum.into(%{user_id: user.id})

      assert {:ok, %Todo{} = todo} = Todos.create_todo(full_attrs)
      assert todo.complete == true
      assert todo.description == "some description"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      user = user_fixture()
      todo = todo_fixture(%{user_id: user.id})

      assert {:ok, todo} = Todos.update_todo(todo, @update_attrs)
      assert %Todo{} = todo
      assert todo.complete == false
      assert todo.description == "some updated description"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      user = user_fixture()
      todo = todo_fixture(%{user_id: user.id})

      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      user = user_fixture()
      todo = todo_fixture(%{user_id: user.id})

      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      user = user_fixture()
      todo = todo_fixture(%{user_id: user.id})

      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end
  end
end
