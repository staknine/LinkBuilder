defmodule LinkBuilder.Admins.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :link_builder,
    error_handler: LinkBuilder.Admins.ErrorHandler,
    module: LinkBuilder.Admins.Guardian

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true

  # Set current admin
  plug LinkBuilderWeb.Plugs.SetCurrentAdmin

  # Set current admin account - when using account swithcher in admin
  plug LinkBuilderWeb.Plugs.SetCurrentAdminAccount
end
