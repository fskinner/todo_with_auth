defmodule TodoWithAuthWeb.UserControllerTest do
  use TodoWithAuthWeb.ConnCase

  alias TodoWithAuth.Authentication
  alias TodoWithAuth.Authentication.User

  @create_attrs %{email: "email1@mail.com", password: "some password"}
  @update_attrs %{email: "update@mail.com", password: "some updated password"}
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "email1@mail.com"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put conn, user_path(conn, :update, user), user: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "update@mail.com"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete conn, user_path(conn, :delete, user)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, user)
      end
    end
  end

  describe "current user" do
    setup [:create_user]
    
    test "renders current user", %{conn: conn, user: user} do
      conn = authenticate_user(conn, user)
      conn = get conn, user_path(conn, :current)
      assert json_response(conn, 200)["data"] == %{
        "id" => user.id,
        "email" => user.email}
    end

    test "renders 403", %{conn: conn}  do
      conn = get conn, user_path(conn, :current)
      assert json_response(conn, 403)["errors"] == %{"detail" => "forbidden"}
    end
  end

  defp authenticate_user(conn, user) do
    {:ok, token, _claims} = TodoWithAuthWeb.Guardian.encode_and_sign(user)
    conn |> put_req_header("authorization", "Bearer #{token}")
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end