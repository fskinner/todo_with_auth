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

  # def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
  #   case AuthUser.basic_info(auth) do
  #     {:ok, user} ->
  #       sign_in_user(conn, %{"user" => user})
  #   end
  # case AuthUser.basic_info(auth) do
  #     {:ok, user} ->
  #       conn
  #       |> render(TodoWithAuthWeb.UserView, "show.json-api", %{data: user})
  #     {:error} ->
  #       conn
  #       |> put_status(401)
  #       |> render(TodoWithAuthWeb.ErrorView, "401.json-api")
  #   end
  # end

  def create(conn, params) do
    # Find the user in the database based on the credentials sent with the request
    with %User{} = user <- Authentication.get_user_by_email!(params.email) do
      # Attempt to authenticate the user
      with {:ok, token, _claims} <- Authentication.authenticate(%{user: user, password: params.password}) do
        # Render the token
        render conn, "token.json", token: token
      end
    end
  end

  # def create(conn, %{"user" => user}) do
  #   try do
  #     # Attempt to retrieve exactly one user from the DB, whose
  #     # email matches the one provided with the login request
  #     user = Authentication.get_user_by_email!(user.email)
  #     cond do
  #       true ->
  #         # Successful login
  #         # Encode a JWT
  #         {:ok, jwt, _} = Guardian.encode_and_sign(user, :token)

  #         auth_conn = Guardian.Plug.api_sign_in(conn, user)

  #         auth_conn
  #         |> put_resp_header("authorization", "Bearer #{jwt}")
  #         |> json(%{access_token: jwt}) # Return token to the client
  #       false ->
  #         # Unsuccessful login
  #         conn
  #         |> put_status(401)
  #         |> render(TodoWithAuthWeb.ErrorView, "401.json")
  #     end
  #   rescue
  #     e ->
  #       IO.inspect e
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
    |> render(TodoWithAuthWeb.ErrorView, "401.json-api")
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