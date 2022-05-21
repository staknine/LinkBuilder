defmodule LinkBuilderWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `LinkBuilderWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, LinkBuilderWeb.Admin.AccountLive.FormComponent,
        id: @account.id || :new,
        action: @live_action,
        account: @account,
        return_to: Routes.account_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    title = Keyword.fetch!(opts, :title)
    modal_opts = [id: :modal, return_to: path, title: title, component: component, opts: opts]
    live_component(LinkBuilderWeb.ModalComponent, modal_opts)
  end

  @doc """
  Maybe show an alert on the admin billing pages if a stripe env variable is not set.
  """
  def stripe_disabled_alert do
    LinkBuilderWeb.Admin.Utils.StripeDisabledAlert.display(%{})
  end
end
