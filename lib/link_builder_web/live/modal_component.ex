defmodule LinkBuilderWeb.ModalComponent do
  use LinkBuilderWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="fixed top-0 left-0 z-50 w-full h-full outline-none" id={@id} role="dialog" style="display: block"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={@myself}
      phx-page-loading>
      <div class="absolute inset-0 z-40 bg-gray-900 opacity-75"></div>
      <div class="relative z-50 w-auto max-w-lg px-4 mx-auto my-8 shadow-lg pointer-events-none sm:px-0">
        <div class="relative flex flex-col w-full border rounded-lg pointer-events-auto text-base-content bg-base-100 border-base-200">
          <div class="flex items-start justify-between p-4 border-b rounded-t border-base-200">
            <h5 class="mb-0 text-lg leading-normal"><%= @title %></h5>
            <%= live_patch raw("&times;"), to: @return_to, class: "btn btn-ghost btn-sm" %>
          </div>
          <div class="relative flex-auto p-4">
            <%= live_component @component, @opts %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
