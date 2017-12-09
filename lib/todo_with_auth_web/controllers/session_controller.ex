defmodule TodoWithAuthWeb.SessionController do
  use TodoWithAuthWeb, :controller

  alias TodoWithAuth.Authentication
  alias TodoWithAuth.Authentication.User

  plug :scrub_params, "user" when action in [:sign_in_user]
  
  action_fallback TodoWithAuthWeb.FallbackController

  def request(_params) do
  end

  def delete(conn, _params) do
    # Sign out the user
    conn
    |> put_status(200)
    |> TodoWithAuthWeb.Guardian.Plug.sign_out
  end

  def create(conn, %{"user" => params}) do
    with {:ok, %User{} = user }<- Authentication.get_user_by_email(params["email"]),
         {:ok, token, claims} <- Authentication.authenticate(%{user: user, password: params["password"]}) do
        
        render conn, "token.json", token: token
      else
        {:error, :not_found} ->
          conn
          |> put_status(404)
          |> render(TodoWithAuthWeb.ErrorView, "404.json")

        {:error, :unauthorized} ->
          conn
          |> put_status(401)
          |> render(TodoWithAuthWeb.ErrorView, "401.json")
          
        error ->
          conn
          |> put_status(500)
          |> render(TodoWithAuthWeb.ErrorView, "500.json")
      end
  end

  # def create(conn, %{"user" => params}) do
  #   try do
  #     with {:ok, %User{} = user} <- Authentication.get_user_by_email!(params["email"]) do
  #       with {:ok, token, claims} <- Authentication.authenticate(%{user: user, password: params["password"]}) do
  #         conn
  #         |> put_resp_header(conn, "authorization", "Bearer #{token}")

  #         render conn, "token.json", token: token
  #       else
  #         conn
  #         |> put_status(401)
  #         |> render(TodoWithAuthWeb.ErrorView, "401.json")
  #       end
  #     else
  #       conn
  #       |> put_status(404)
  #       |> render(TodoWithAuthWeb.ErrorView, "404.json")
  #     end
  #   rescue
  #     e ->
  #       Logger.error(["Failed login attempt", inspect(e)])
  #   end
  # end

  # def sign_up_user(conn, %{"user" => user}) do
  #   changeset = User.changeset %User{}, %{email: user.email,
  #     avatar: user.avatar,
  #     first_name: user.first_name,
  #     last_name: user.last_name,
  #     auth_provider: "google"}
  #   case Repo.insert changeset do
  #     {:ok, user} ->
  #       # Encode a JWT
  #       { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)
  #       conn
  #       |> put_resp_header("authorization", "Bearer #{jwt}")
  #       |> json(%{access_token: jwt}) # Return token to the client
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(422)
  #       |> render(TodoWithAuthWeb.ErrorView, "422.json-api")
  #   end
  # end

  def show(conn, _) do
    user = conn
    |> Guardian.Plug.current_resource

    conn
    |> render(TodoWithAuthWeb.UserView, "show.json", user: user)
  end

  def unauthenticated(conn, _) do
    conn
    |> put_status(401)
    |> render(TodoWithAuthWeb.ErrorView, "401.json")
  end

  def unauthorized(conn, _) do
    conn
    |> put_status(403)
    |> render(TodoWithAuthWeb.ErrorView, "403.json")
  end

  def no_resource(conn, _) do
    conn
    |> put_status(404)
    |> render(TodoWithAuthWeb.ErrorView, "404.json")
  end
end