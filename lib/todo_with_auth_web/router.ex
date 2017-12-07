defmodule TodoWithAuthWeb.Router do
  use TodoWithAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug TodoWithAuthWeb.Guardian.AuthPipeline
  end

  scope "/api", MyAppWeb.Api do
    pipe_through [:api, :api_auth]
  
    resources "/sessions", SessionController, only: [:update, :show, :delete]
  end

  scope "/api", TodoWithAuthWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end
end
