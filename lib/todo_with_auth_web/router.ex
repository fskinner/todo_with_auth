defmodule TodoWithAuthWeb.Router do
  use TodoWithAuthWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug TodoWithAuthWeb.Guardian.AuthPipeline
  end

  scope "/api", TodoWithAuthWeb do
    pipe_through :api
  
    resources "/users", UserController#, only: [:create]
    post "/sessions", SessionController, :create
    delete "/sessions", SessionController, :delete
  end

  scope "/api", TodoWithAuthWeb do
    pipe_through [:api, :api_auth]

    resources "/users", UserController#, except: [:new, :edit, :create, :index]
  end
end
