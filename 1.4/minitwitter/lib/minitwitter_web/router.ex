defmodule MinitwitterWeb.Router do
  use MinitwitterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MinitwitterWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", MinitwitterWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/home", PageController, :home
    get "/contact", PageController, :contact
    get "/signup", UserController, :new

    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/account_activations", AccountActivationsController, only: [:edit]
    get "/*path", ErrorController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MinitwitterWeb do
  #   pipe_through :api
  # end
end
