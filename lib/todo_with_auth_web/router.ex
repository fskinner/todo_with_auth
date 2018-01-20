defmodule TodoWithAuthWeb.Router do
  use TodoWithAuthWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug(TodoWithAuthWeb.Guardian.AuthPipeline)
    plug(TodoWithAuthWeb.CurrentUserPlug)
  end

  scope "/api", TodoWithAuthWeb do
    pipe_through(:api)

    resources("/users", UserController, except: [:new, :edit])
    post("/sessions", SessionController, :create)
    delete("/sessions", SessionController, :delete)
  end

  scope "/api", TodoWithAuthWeb do
    pipe_through([:api, :api_auth])

    get("/current-user", UserController, :current)
    resources("/todos", TodoController, except: [:new, :edit])
  end
end
