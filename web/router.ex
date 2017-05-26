defmodule Server.Router do
  use Server.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Server do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", Server do
    pipe_through :api

    get "/", APIController, :index
    get "/get_blocks", APIController, :get_blocks
    get "/get_difficulty", APIController, :get_difficulty
    get "/add_block", APIController, :add_block
    get "/confirm_block", APIController, :confirm_block
  end
end
