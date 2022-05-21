defmodule LinkBuilderWeb.App.BillingLive.CreditCardFormComponent do
  use LinkBuilderWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, loading: false)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
    }
  end

  @impl true
  def handle_event("submit", _, socket) do
    {:noreply, assign(socket, loading: true)}
  end
end
