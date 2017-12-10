defmodule TodoWithAuthWeb.SessionController do
  use TodoWithAuthWeb, :controller

  alias TodoWithAuth.Authentication
  alias TodoWithAuth.Authentication.User

  plug :scrub_params, "user" when action in [:create]
  
  action_fallback TodoWithAuthWeb.FallbackController

  def create(conn, %{"user" => params}) do
    with {:ok, %User{} = user }<- Authentication.get_user_by_email(params["email"]),
      {:ok, token, _} <- Authentication.authenticate(%{user: user, password: params["password"]}) do
        
        render conn, "token.json", token: token
      else
        {:error, :not_found} -> not_found(conn, params)
        {:error, :unauthorized} -> unauthorized(conn, params)

        error ->
          IO.inspect error
          internal_server_error(conn, params)
      end
  end

  def delete(conn, _params) do
    conn
    |> TodoWithAuthWeb.Guardian.Plug.sign_out
    |> send_resp(:no_content, "")
  end

  def unauthorized(conn, _) do
    conn
    |> put_status(401)
    |> render(TodoWithAuthWeb.ErrorView, "401.json")
  end

  def internal_server_error(conn, _) do
    conn
    |> put_status(500)
    |> render(TodoWithAuthWeb.ErrorView, "500.json")
  end

  def not_found(conn, _) do
    conn
    |> put_status(404)
    |> render(TodoWithAuthWeb.ErrorView, "404.json")
  end
end