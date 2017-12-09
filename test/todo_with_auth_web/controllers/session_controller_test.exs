defmodule TodoWithAuthWeb.SessionControllerTest do
  use TodoWithAuthWeb.ConnCase

  alias TodoWithAuth.Authentication

  @valid_login_attrs %{email: "email1@mail.com", password: "some password"}
  @wrong_email_attrs %{email: "2@mail.com", password: "some password"}
  @wrong_pass_attrs %{email: "email1@mail.com", password: "wrong password"}

  def fixture(:user) do
    {:ok, user} = Authentication.create_user(@valid_login_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    setup [:create_user]

    test "renders token", %{conn: conn} do
      conn = post conn, session_path(conn, :create), user: @valid_login_attrs
      assert json_response(conn, 200)["token"] != nil
    end

    test "renders 404 when email doesnt match", %{conn: conn}  do
      conn = post conn, session_path(conn, :create), user: @wrong_email_attrs
      assert json_response(conn, 404)["errors"] == %{"detail" => "Page not found"}
    end

    test "renders 401 when password doesnt match", %{conn: conn}  do
      conn = post conn, session_path(conn, :create), user: @wrong_pass_attrs
      assert json_response(conn, 401)["errors"] == %{"detail" => "Unauthorized"}
    end
  end

  describe "delete" do
    test "renders no content", %{conn: conn} do
      conn = delete conn, session_path(conn, :delete)
      assert response(conn, 204)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
