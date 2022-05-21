defmodule LinkBuilderWeb.SubscriptionLive.New do
  use LinkBuilderWeb, :live_view

  import Ecto.Changeset

  alias LinkBuilder.Billing

  @stripe_service Application.get_env(:link_builder, :stripe_service)

  on_mount LinkBuilderWeb.App.InitAssigns

  @impl true
  def mount(_params, _session, socket) do
    Billing.WebhookProcessor.subscribe()

    customer = Billing.get_billing_customer_for_account(socket.assigns.account)

    products = get_products()
    initial_plan_id = get_initial_plan_id(products)

    {
      :ok,
      socket
      |> assign(:changeset, changeset(%{plan_id: initial_plan_id}))
      |> assign(:customer, customer)
      |> assign(:plan_id, initial_plan_id)
      |> assign(:products, products)
      |> assign(:error_message, nil)
      |> assign(:loading, false)
      |> assign(:retry, false)
    }
  end

  @impl true
  def handle_event("update-plan", %{"price" => %{"plan_id" => plan_id}}, socket) do
    {
      :noreply,
      socket
      |> assign(:plan_id, plan_id)
      |> assign(:changeset, changeset(%{plan_id: plan_id}))
    }
  end

  def handle_event("is-loading", %{"loading" => loading}, socket) do
    {:noreply, assign(socket, :loading, loading)}
  end

  def handle_event("payment-method-created", %{"id" => payment_method_id}, socket) do
    customer = socket.assigns.customer
    create_and_attach_payment_method(customer.stripe_id, payment_method_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:event, event}, socket) do
    event
    |> filter_event_for_current_customer(socket.assigns.customer)
    |> Map.get(:type)
    |> case do
      "payment_method.attached" ->
        if socket.assigns.retry do
          {:noreply, socket}
        else
          create_subscription(socket)
        end
      "payment_intent.requires_action" -> requires_action(event.data.object, socket)
      "payment_intent.payment_failed" -> payment_failed(socket)
      "payment_intent.succeeded" -> payment_succeeded(socket)
      _ -> {:noreply, socket}
    end
  end

  defp filter_event_for_current_customer(event, customer) do
    if Map.get(event.data.object, :customer) == customer.stripe_id do
      event
    else
      Map.put(event, :type, nil)
    end
  end

  defp requires_action(payment_intent, socket) do
    {
      :noreply,
      socket
      |> push_event("requires_action",
        %{client_secret: payment_intent.client_secret, payment_method_id: payment_intent.payment_method}
      )
    }
  end

  defp payment_failed(socket) do
    {
      :noreply,
      socket
      |> assign(:loading, false)
      |> assign(:error_message, "There was an error processing this card.")
    }
  end

  defp payment_succeeded(socket) do
    {
      :noreply,
      socket
      |> assign(:loading, false)
      |> assign(:error_message, nil)
      |> put_flash(:info, "The subscription was created successfully.")
      |> redirect(to: Routes.app_home_path(socket, :index))
    }
  end

  defp changeset(attrs) do
    cast({%{}, %{stripe_id: :string}}, attrs, [:stripe_id])
  end

  defp get_initial_plan_id(products) do
    # [
    #   {"Monthly subscription", [{"Standard Plan - $9", 4}, {"Premium Plan - $19", 5}]},
    #   {"Yearly subscription", [{"Standard Plan - $99", 3}, {"Premium Plan - $199", 6}]}
    # ]
    case products do
      [{_, [{_, plan_id} | _]} | _] -> plan_id
      _ -> nil
    end
  end

  defp get_products() do
    Billing.list_plans_for_subscription_page()
    |> Enum.group_by(&Map.get(&1, :period))
    |> Enum.reduce([], fn {period, plans}, acc ->
      plans = Enum.map(plans, fn plan -> {format_plan_name(plan), plan.id} end)
      period = String.capitalize("#{period}ly subscription")

      Enum.concat(acc, [{period, plans}])
    end)
  end

  defp format_plan_name(plan) do
    "#{plan.name} - #{format_price(plan.amount)}"
  end

  defp format_price(amount) do
    rounded_amount = round(amount / 100)
    "$#{rounded_amount}"
  end

  defp create_and_attach_payment_method(customer_stripe_id, payment_method_id) do
    {:ok, payment_method} =
      @stripe_service.PaymentMethod.attach(%{
        customer: customer_stripe_id,
        payment_method: payment_method_id
      })

    @stripe_service.Customer.update(customer_stripe_id, %{
      invoice_settings: %{default_payment_method: payment_method.id}
    })
  end

  defp create_subscription(socket) do
    %{customer: customer, plan_id: plan_id} = socket.assigns
    price_stripe_id = Billing.get_plan!(plan_id).stripe_id

    {:ok, subscription} =
      @stripe_service.Subscription.create(%{
        customer: customer.stripe_id,
        items: [%{price: price_stripe_id}]
      })

    {:ok, invoice} = @stripe_service.Invoice.retrieve(subscription.latest_invoice)
    {:ok, _payment_intent} = @stripe_service.PaymentIntent.retrieve(invoice.payment_intent, %{})

    {:noreply, socket}
  end
end
