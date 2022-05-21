defmodule LinkBuilderWeb.SharedComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  def heading(assigns) do
    ~H"""
    <div class="flex items-center justify-between pb-4 mt-4 mb-12 border-b border-base-200">
      <h3 class="text-2xl font-bold sm:text-4xl">
        <%= render_block(@inner_block) %>
      </h3>
    </div>
    """
  end

  def card(assigns) do
    ~H"""
    <div class={"card bg-base-100 rounded shadow border border-base-200 #{assigns[:class]}"}>
      <div class="card-body">
        <%= render_block(@inner_block) %>
      </div>
    </div>
    """
  end

  def alert(assigns) do
    ~H"""
    <div class={"alert alert-#{assigns[:type] || "type"}"}>
      <%= render_block(@inner_block) %>
    </div>
    """
  end

  def dropdown(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "dom#{System.unique_integer()}" end)

    ~H"""
    <div class="relative inline-block text-left">
      <button phx-click={ JS.toggle(to: "##{@id}", in: {"duration-300", "opacity-0", "opacity-100"}, out: {"duration-75", "opacity-100", "opacity-0"})  } >
        <%= render_slot(@toggle) %>
      </button>
      <div id={@id} class="absolute right-0 z-20 hidden" phx-click-away={JS.hide(to: "##{@id}", transition: {"duration-75", "opacity-100", "opacity-0"})}>
        <%= render_slot(@inner_block, assigns) %>
      </div>
    </div>
    """
  end
end
