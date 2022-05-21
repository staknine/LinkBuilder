defmodule LinkBuilder.Emails do
  import Swoosh.Email
  use Phoenix.Swoosh, view: LinkBuilderWeb.EmailView, layout: {LinkBuilderWeb.LayoutView, :email}

  @from Application.get_env(:link_builder, :from_email)

  @doc """
  This email is sent when using the notifications module
  """
  def notification_email(%{email: email}, %{title: title, body: body}) do
    base_email()
    |> subject(title)
    |> to(email)
    |> render_body("notification.html",
      title: title,
      preheader: body,
      body: body
    )
    |> premail()
  end

  @doc """
  This email is sent when a user has registered an account
  """
  def welcome_email(%{email: email}) do
    base_email()
    |> subject("Welcome!")
    |> to(email)
    |> render_body("welcome.html",
      title: "Thank you for signing up",
      preheader: "Thank you for signing up to the app."
    )
    |> premail()
  end

  @doc """
  This email is used from the Teams module to invite a new user to an account
  """
  def invite_user_email(%{email: email, url: url}) do
    base_email()
    |> subject("Invited to join")
    |> to(email)
    |> render_body("invite_user.html", title: "Invited to join", url: url)
    |> premail()
  end

  @doc """
  This email is used when an admin needs to login with a magic link
  """
  def admin_login_link(%{email: email, url: url}) do
    base_email()
    |> subject("Login token")
    |> to(email)
    |> render_body("admin_login_link.html", title: "Login token", url: url)
    |> premail()
  end

  # Base email function should contain all common features
  defp base_email do
    new()
    |> from(@from)
  end

  # Inline CSS so it works in all browsers
  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end
end
