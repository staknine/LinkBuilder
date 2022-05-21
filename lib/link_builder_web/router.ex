defmodule LinkBuilderWeb.Router do
  use LinkBuilderWeb, :router

  import LinkBuilderWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LinkBuilderWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LinkBuilder.Admins.Pipeline
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug LinkBuilderWeb.Context
  end

  # Set the layout for when a user registers or signs in
  pipeline :session_layout do
    plug :put_root_layout, {LinkBuilderWeb.LayoutView, :session}
  end

  # Set the layout for when an admin signs in
  pipeline :admin_session_layout do
    plug :put_root_layout, {LinkBuilderWeb.Admin.LayoutView, :session}
  end

  # Set the main layout for the actual application
  pipeline :app_layout do
    plug :put_root_layout, {LinkBuilderWeb.App.LayoutView, :root}
  end

  # Set the main layout for the admin area
  pipeline :admin_layout do
    plug :put_root_layout, {LinkBuilderWeb.Admin.LayoutView, :root}
  end

  pipeline :require_active_subscription do
    plug LinkBuilderWeb.Plugs.RequireActiveSubscription
  end

  pipeline :require_current_admin do
    plug LinkBuilderWeb.Plugs.RequireCurrentAdmin
  end

  scope "/app" do
    pipe_through [:browser, :session_layout, :require_authenticated_user]

    live "/subscriptions/new", LinkBuilderWeb.SubscriptionLive.New, :new
    delete "/sign_out", LinkBuilderWeb.UserSessionController, :delete
    get "/settings/confirm_email/:token", LinkBuilderWeb.UserSettingsController, :confirm_email
  end

  scope "/", LinkBuilderWeb do
    pipe_through :browser

    get "/privacy", PageController, :privacy
    get "/terms-and-conditions", PageController, :terms
    live "/pricing", PricingLive, :index
    live "/", PageLive, :index
  end

  scope "/webhooks", LinkBuilderWeb do
    pipe_through :api

    post "/stripe", StripeWebhookController, :create
  end

  scope "/", LinkBuilderWeb do
    pipe_through [:browser, :session_layout, :redirect_if_user_is_authenticated]

    get "/invitation/:token", InvitationController, :new
    post "/invitation", InvitationController, :create

    get "/sign_up", AccountRegistrationController, :new
    post "/sign_up", AccountRegistrationController, :create

    get "/sign_in", UserSessionController, :new
    post "/sign_in", UserSessionController, :create
    get "/reset_password", UserResetPasswordController, :new
    post "/reset_password", UserResetPasswordController, :create
    get "/reset_password/:token", UserResetPasswordController, :edit
    put "/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", LinkBuilderWeb do
    pipe_through [:browser]

    # delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  scope "/app", LinkBuilderWeb.App, as: :app do
    pipe_through [:browser, :app_layout, :require_authenticated_user, :require_active_subscription]
    # pipe_through [:browser, :app_layout, :require_current_user]

    live "/", HomeLive, :index
    live "/settings", UserLive.Edit, :edit
    live "/billing", BillingLive.Index, :index
    live "/team", TeamLive.Index, :index
  end

  scope "/admin", LinkBuilderWeb.Admin, as: :admin do
    pipe_through [:browser, :admin_session_layout]

    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
    delete "/sign_out", SessionController, :delete
    get "/reset_password", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_password/:token", ResetPasswordController, :show
  end

  scope "/admin", LinkBuilderWeb.Admin, as: :admin do
    pipe_through [:browser, :require_current_admin, :admin_layout]

    live "/", DashboardLive.Index, :index
    live "/settings", SettingLive.Edit, :edit

    post "/account_switch/:token", AccountSwitchController, :create
    post "/impersonate/:account_id/:id", UserImpersonationController, :create

    live "/accounts", AccountLive.Index, :index
    live "/accounts/new", AccountLive.Index, :new
    live "/accounts/:id/edit", AccountLive.Index, :edit
    live "/accounts/:id/billing_customer", AccountLive.Index, :billing_customer

    live "/accounts/:id", AccountLive.Show, :show
    live "/accounts/:id/show/edit", AccountLive.Show, :edit

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/notify", UserLive.Index, :notify
    live "/users/:id", UserLive.Show, :show

    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id/edit", ProductLive.Index, :edit

    live "/products/:id", ProductLive.Show, :show
    live "/products/:id/show/edit", ProductLive.Show, :edit

    live "/plans", PlanLive.Index, :index
    live "/plans/new", PlanLive.Index, :new
    live "/plans/:id/edit", PlanLive.Index, :edit

    live "/plans/:id", PlanLive.Show, :show
    live "/plans/:id/show/edit", PlanLive.Show, :edit

    live "/invoices", InvoiceLive.Index, :index
    live "/subscriptions", SubscriptionLive.Index, :index

    live "/jobs", BackgroundJobLive.Index, :index
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: LinkBuilderWeb.Schema
  end

  if Application.get_env(:link_builder, :env) == :dev do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: LinkBuilderWeb.Schema
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Application.get_env(:link_builder, :env) in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/admin" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LinkBuilderWeb.Telemetry, ecto_repos: [LinkBuilder.Repo]
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Application.get_env(:link_builder, :env) == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
