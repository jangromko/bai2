defmodule Bai2Web.Router do
  use Bai2Web, :router

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

  scope "/", Bai2Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/login", PageController, :login
    post "/login", PageController, :log_in
    get "/logout", PageController, :logout
    get "/register", PageController, :register
    post "/register", PageController, :register_post
    get "/account_details", PageController, :account_details
    get "/set_account_details", PageController, :set_account_details
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bai2Web do
  #   pipe_through :api
  # end
end
