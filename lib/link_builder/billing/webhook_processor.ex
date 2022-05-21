defmodule LinkBuilder.Billing.WebhookProcessor do
  @moduledoc """
  """
  use GenServer

  alias LinkBuilderWeb.StripeWebhookController
  alias LinkBuilder.Billing.SynchronizeProducts
  alias LinkBuilder.Billing.SynchronizePlans
  alias LinkBuilder.Billing.HandleSubscriptions
  alias LinkBuilder.Billing.HandleInvoices
  alias LinkBuilder.Billing.HandlePaymentMethods

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(state) do
    StripeWebhookController.subscribe_on_webhook_recieved()
    {:ok, state}
  end

  def handle_info(%{event: event}, state) do
    notify_subscribers(event)

    case event.type do
      "product.created" -> SynchronizeProducts.run()
      "product.updated" -> SynchronizeProducts.run()
      "product.deleted" -> SynchronizeProducts.run()
      "plan.created" -> SynchronizePlans.run()
      "plan.updated" -> SynchronizePlans.run()
      "plan.deleted" -> SynchronizePlans.run()
      "customer.updated" -> nil
      "customer.deleted" -> nil
      "customer.subscription.updated" -> HandleSubscriptions.update_subscription(event.data.object)
      "customer.subscription.deleted" -> HandleSubscriptions.update_subscription(event.data.object)
      "customer.subscription.created" -> HandleSubscriptions.create_subscription(event.data.object)
      "invoice." <> _ -> HandleInvoices.create_or_update_invoice(event.data.object)
      "payment_method.attached" -> HandlePaymentMethods.add_card_info(event.data.object)
      "payment_method.detached" -> HandlePaymentMethods.remove_card_info(event.data.object)
      _ -> nil
    end

    {:noreply, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(LinkBuilder.PubSub, "webhook_processed")
  end

  def notify_subscribers(event) do
    Phoenix.PubSub.broadcast(LinkBuilder.PubSub, "webhook_processed", {:event, event})
  end

  defmodule Stub do
    use GenServer
    def start_link(_), do: GenServer.start_link(__MODULE__, nil)
    def init(state), do: {:ok, state}
  end
end
