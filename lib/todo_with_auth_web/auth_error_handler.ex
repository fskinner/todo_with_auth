defmodule TodoWithAuthWeb.Guardian.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    case type do
      :unauthenticated ->
        message = :forbidden
        code = 403
      _ ->
        message = :internal_server_error
        code = 500
    end
    
    body = Poison.encode!(
      %{errors: %{detail: to_string(message)}}
    )
    
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(code, body)
  end
end