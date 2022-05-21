defmodule LinkBuilderWeb.Admin.AccountLive.BillingCustomerFormComponent do
  use LinkBuilderWeb, :live_component

  import Ecto.Changeset

  alias LinkBuilder.Accounts

  @impl true
  def update(%{id: id} = assigns, socket) do
    account = Accounts.get_account!(id)

    first_email =
      case Accounts.list_users(account) do
        [%{email: email} | _] -> email
        _ -> nil
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, stripe_customer_changeset(%{email: first_email}))}
  end

  @impl true
  def handle_event("validate", %{"stripe_customer" => stripe_customer_params}, socket) do
    changeset =
      stripe_customer_changeset(stripe_customer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"stripe_customer" => %{"email" => email} = params}, socket) do
    stripe_customer_changeset(params)
    |> Map.put(:action, :validate)
    |> case do
      %Ecto.Changeset{valid?: true} ->
        account = socket.assigns.account
        LinkBuilder.Billing.CreateStripeCustomer.create_customer_in_stripe(%{account: account, email: email})

        {:noreply,
         socket
         |> put_flash(:info, "Billing Customer is created")
         |> push_redirect(to: socket.assigns.return_to)}

      %Ecto.Changeset{} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp stripe_customer_changeset(attrs) do
    cast(
      {%{}, %{email: :string}},
      attrs,
      [:email]
    )
    |> validate_required([:email])
  end
end
