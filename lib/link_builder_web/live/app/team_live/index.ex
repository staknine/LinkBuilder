defmodule LinkBuilderWeb.App.TeamLive.Index do
  use LinkBuilderWeb, :live_view

  alias LinkBuilder.Accounts

  on_mount LinkBuilderWeb.App.InitAssigns

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users(socket.assigns.account)

    {
      :ok,
      socket
      |> assign(:users, users)
    }
  end
end
