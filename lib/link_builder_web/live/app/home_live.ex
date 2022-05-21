defmodule LinkBuilderWeb.App.HomeLive do
  use LinkBuilderWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
