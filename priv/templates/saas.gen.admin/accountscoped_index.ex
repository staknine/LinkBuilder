defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Index do
  use <%= inspect context.web_module %>, :live_view_admin
  use Saas.DataTable

  alias <%= inspect context.module %>
  alias <%= inspect schema.module %>

  on_mount {<%= inspect context.web_module %>.Admin.InitAssigns, :require_account}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    account = socket.assigns.account

    {
      :noreply,
      socket
      |> assign(:params, params)
      |> assign(get_<%= schema.plural %>_assigns(account, params))
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    account = socket.assigns.account

    socket
    |> assign(:page_title, "Edit <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, <%= inspect context.alias %>.get_<%= schema.singular %>!(account, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New <%= schema.human_singular %>")
    |> assign(:<%= schema.singular %>, %<%= inspect schema.alias %>{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing <%= schema.human_plural %>")
    |> assign(:<%= schema.singular %>, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = socket.assigns.account
    <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>!(account, id)
    {:ok, _} = <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>)

    {:noreply, assign(socket, get_<%= schema.plural %>_assigns(account, %{}))}
  end

  defp get_<%= schema.plural %>_assigns(account, params) do
    case <%= inspect context.alias %>.paginate_<%= schema.plural %>(account, params) do
      {:ok, assigns} -> assigns
      _ -> %{}
    end
  end
end
