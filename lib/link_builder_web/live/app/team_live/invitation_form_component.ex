defmodule LinkBuilderWeb.App.TeamLive.InvitationFormComponent do
  use LinkBuilderWeb, :live_component

  import Ecto.Changeset
  alias LinkBuilder.Teams

  @impl true
  def update(assigns, socket) do
    changeset = email_changeset()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      email_changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => %{"email" => email} = params}, socket) do
    email_changeset(params)
    |> Map.put(:action, :validate)
    |> case do
      %Ecto.Changeset{valid?: true} ->
        user = socket.assigns.user
        Teams.invite_member(%{account_id: user.account_id, email: email})

        LinkBuilder.Notifications.flash(user, "Invitation sent")

        {:noreply,
         socket
         |> push_event("close", %{id: "invitation-modal"})}

      %Ecto.Changeset{} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp email_changeset(attrs \\ %{}) do
    cast(
      {%{}, %{email: :string}},
      attrs,
      [:email]
    )
    |> validate_required([:email])
  end
end
