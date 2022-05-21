defmodule LinkBuilderWeb.Admin.Utils.AccountSwitcherLive do
  use LinkBuilderWeb, :live_view_no_layout

  import Ecto.Changeset

  alias LinkBuilder.Accounts

  @impl true
  def mount(_params, session, socket) do
    accounts =
      Accounts.list_accounts()
      |> Enum.sort_by(& &1.name)


    current_account =
      case session do
        %{"admin_account_id" => account_id} -> Enum.find(accounts, & &1.id == account_id)
        _ -> nil
      end

    {
      :ok,
      socket
      |> assign(:current_account, current_account)
      |> assign(:accounts, accounts)
      |> assign(:filtered_accounts, accounts)
      |> assign(:changeset, filter_changeset())
    }
  end

  @impl true
  def handle_event("filter", %{"filter" => %{"account_name" => account_name}}, socket) when account_name == "" do
    accounts = socket.assigns.accounts
    {:noreply, assign(socket, :filtered_accounts, accounts)}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter}, socket) do
    accounts = socket.assigns.accounts

    filter
    |> filter_changeset()
    |> case do
      %{valid?: true, changes: %{account_name: account_name}} ->
        {:noreply, assign(socket, :filtered_accounts, filter(accounts, account_name))}
      _ ->
        {:noreply, socket}
    end
  end

  @types %{account_name: :string}
  defp filter_changeset(attrs \\ %{}) do
    cast(
      {%{}, @types},
      attrs,
      [:account_name]
    )
    |> validate_required([:account_name])
    |> update_change(:account_name, &String.trim/1)
    |> update_change(:account_name, &String.downcase/1)
  end

  defp filter(accounts, account_name) do
    accounts
    |> Enum.filter(fn %{name: name} ->
      name
      |> String.downcase()
      |> String.starts_with?(account_name)
    end)
  end
end
