defmodule LinkBuilderWeb.Admin.AccountLive.Index do
  use LinkBuilderWeb, :live_view_admin
  use Saas.DataTable

  alias LinkBuilder.Accounts
  alias LinkBuilder.Accounts.Account

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {
      :noreply,
      socket
      |> assign(:params, params)
      |> assign(get_accounts_assigns(params))
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, Accounts.get_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Accounts")
    |> assign(:account, nil)
  end

  defp apply_action(socket, :billing_customer, %{"id" => id}) do
    socket
    |> assign(:page_title, "Add Billing Customer")
    |> assign(:account, Accounts.get_account!(id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounts.get_account!(id)
    {:ok, _} = Accounts.delete_account(account)

    {:noreply, assign(socket, get_accounts_assigns(%{}))}
  end

  defp get_accounts_assigns(params) do
    case Accounts.paginate_accounts(params) do
      {:ok, assigns} -> assigns
      _ -> %{}
    end
  end
end
