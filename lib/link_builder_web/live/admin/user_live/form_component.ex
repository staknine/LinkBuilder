defmodule LinkBuilderWeb.Admin.UserLive.FormComponent do
  use LinkBuilderWeb, :live_component

  alias LinkBuilder.Accounts

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user_registration(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    user_params = Map.merge(user_params, autogenereated_password())

    changeset =
      socket.assigns.user
      |> Accounts.change_user_registration(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = Map.merge(user_params, autogenereated_password())

    case Accounts.register_user(socket.assigns.account, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp autogenereated_password() do
    password = :crypto.strong_rand_bytes(10) |> Base.encode64()
    %{"password" => password, "password_confirmation" => password}
  end
end
