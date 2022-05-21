defmodule LinkBuilder.Billing.WebhookProcessorTest do
  use LinkBuilder.DataCase

  @stripe_service Application.get_env(:link_builder, :stripe_service)

  alias LinkBuilder.Billing.WebhookProcessor
  alias LinkBuilderWeb.StripeWebhookController

  def event_fixture(attrs \\ %{}) do
    @stripe_service.Event.generate(attrs)
  end

  describe "listen for and processing a stripe event" do
    test "processes incoming events after broadcasing it" do
      start_supervised(WebhookProcessor, [])
      WebhookProcessor.subscribe()

      event = event_fixture()
      StripeWebhookController.notify_subscribers(event)

      assert_receive {:event, _}
    end
  end
end
