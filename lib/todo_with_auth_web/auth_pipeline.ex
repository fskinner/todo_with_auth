defmodule TodoWithAuthWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :todo_with_auth,
    module: TodoWithAuthWeb.Guardian,
    error_handler: TodoWithAuthWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated

  #check this afterwards
  plug Guardian.Plug.LoadResource
end