defmodule TodoWithAuthWeb.TodoControllerTest do
  use TodoWithAuthWeb.ConnCase

  alias TodoWithAuth.Main
  alias TodoWithAuth.Main.Todo
  alias TodoWithAuth.Authentication

  @create_attrs %{complete: true, description: "some description"}
  @update_attrs %{complete: false, description: "some updated description"}
  @invalid_attrs %{complete: nil, description: nil}
  @user_attrs %{email: "email1@mail.com", password: "some password"}

  def fixture(:todo) do
    {:ok, todo} = Main.create_todo(@create_attrs)
    todo
  end

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    conn = conn
          |> put_req_header("accept", "application/json")
          |> put_req_header("content-type", "application/json")

    {:ok, conn: conn}
  end

  describe "index" do
    setup [:create_user]

    test "lists all todos", %{conn: conn, user: user} do
      conn = authenticate_user(conn, user)
      conn = get conn, todo_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create todo" do
    setup [:create_user]
    
    test "renders todo when data is valid", %{conn: conn, user: user} do
      conn = authenticate_user(conn, user)
      conn = post conn, todo_path(conn, :create), todo: @create_attrs
      new_todo = json_response(conn, 201)["data"]

      assert new_todo["complete"] == true
      assert new_todo["description"] == "some description"
      assert new_todo["user_id"] == user.id
      assert new_todo["id"] != nil
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = authenticate_user(conn, user)
      conn = post conn, todo_path(conn, :create), todo: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  # describe "update todo" do
  #   setup [:create_user, :create_todo]

  #   test "renders todo when data is valid", %{conn: conn, todo: %Todo{id: id} = todo} do
  #     conn = put conn, todo_path(conn, :update, todo), todo: @update_attrs
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get conn, todo_path(conn, :show, id)
  #     assert json_response(conn, 200)["data"] == %{
  #       "id" => id,
  #       "complete" => false,
  #       "description" => "some updated description",
  #       "user_id"=> nil
  #     }
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, todo: todo} do
  #     conn = put conn, todo_path(conn, :update, todo), todo: @invalid_attrs
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete todo" do
  #   setup [:create_todo]

  #   test "deletes chosen todo", %{conn: conn, todo: todo} do
  #     conn = delete conn, todo_path(conn, :delete, todo)
  #     assert response(conn, 204)
  #     assert_error_sent 404, fn ->
  #       get conn, todo_path(conn, :show, todo)
  #     end
  #   end
  # end

  defp authenticate_user(conn, user) do
    {:ok, token, _claims} = TodoWithAuthWeb.Guardian.encode_and_sign(user)
    conn |> put_req_header("authorization", "Bearer #{token}")
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp create_todo(_) do
    todo = fixture(:todo)
    {:ok, todo: todo}
  end
  
end
