defmodule LinkBuilderWeb.Live.Admin.Components.ModalComponent do
  use Phoenix.Component
  import Phoenix.HTML
  alias Phoenix.LiveView.JS

  def modal(assigns) do
    ~H"""
    <div class="fixed top-0 left-0 z-50 w-full h-screen outline-none" id="modal" role="dialog"
      data-init-modal={open_modal()} phx-remove={close_modal()}>
      <div class="absolute inset-0 z-40 bg-gray-900 opacity-75"></div>
      <div class="w-full h-full overflow-x-scroll">
        <div
          phx-click-away={JS.dispatch("click", to: "#close")}
          phx-window-keydown={JS.dispatch("click", to: "#close")}
          phx-key="escape"
          id="modal-content"
          class="relative z-50 w-auto max-w-lg px-4 mx-auto my-8 shadow-lg poiner-events-none sm:px-0">
          <div class="relative flex flex-col w-full border rounded-lg pointer-events-auto text-base-content bg-base-100 border-base-200">
            <div class="flex items-start justify-between p-4 border-b rounded-t border-base-200">
              <h5 class="mb-0 text-lg leading-normal"><%= if assigns[:modal_title], do: render_slot @modal_title %></h5>
              <%= live_patch raw("&times;"), to: @return_to, phx_click: close_modal(), id: "close", class: "btn btn-ghost btn-sm" %>
            </div>
            <div class="relative flex-auto p-4 ">
              <%= render_slot(@inner_block, assigns) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp open_modal(js \\ %JS{}) do
    js
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.transition("fade-in", to: "#modal")
    |> JS.transition("modal-content-in", to: "#modal-content")
  end

  defp close_modal(js \\ %JS{}) do
    js
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "modal-content-out")
  end
end
