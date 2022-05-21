defmodule LinkBuilder.Notifications do
  @moduledoc """
  Contains all notifications that can be sent within the app.
  """
  use Saas.NotificationCenter

  alias LinkBuilder.Notifications.Notifiers

  @doc """
  Sends a general message to one or all of these delivery types.
  The types can be: "all", "db", "flash", "email"

  ## Examples

      iex> general(user, %Saas.Message{title: "some title", type: "all"})

      iex> general(user, %Saas.Message{title: "some title", body: "content of the email", type: "email"})

  """
  def general(user, message) do
    [
      %Notifiers.Db{user: user, message: message},
      %Notifiers.Flash{user: user, message: message},
      %Notifiers.Email{user: user, message: message}
    ]
    |> Enum.each(&send_notification/1)
  end

  @doc """
  Sends a flash message to a specific user. This is only visible
  if the user signed in.

  ## Examples

      iex> flash(user, "the flash message")
  """
  def flash(user, text) do
    %Notifiers.Flash{user: user, message: %Message{title: text, type: "flash"}}
    |> send_notification()
  end

  @doc """
  There is also the possibility to create a specific notification type
  that contains hardcoded content here.

  This can be called after a user has signed up and will result in a notification showing up in the
  notification icon on the app dashboard.
  """
  def signup(user) do
    title = "Welcome"

    body = """
    How to get started. Replace this text later.
    """

    [
      %Notifiers.Db{user: user, message: %{type: "db", title: title, body: body}},
    ]
    |> Enum.each(&send_notification/1)
  end
end
