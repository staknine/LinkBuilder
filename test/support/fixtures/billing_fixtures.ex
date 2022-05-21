defmodule LinkBuilder.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LinkBuilder.Billing` context.
  """

  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Billing.{Product, Products, Plans, Customers, Subscriptions, Invoices}
  alias LinkBuilder.Accounts.Account

  def unique_stripe_id, do: "foo_#{MockStripe.token()}"

  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{name: "Premium Plan"})
      |> Products.create_product()

    product
  end

  def customer_fixture(), do: customer_fixture(%{})
  def customer_fixture(%Account{} = account), do: customer_fixture(account, %{})

  def customer_fixture(attrs) do
    account = account_fixture()
    customer_fixture(account, attrs)
  end

  def customer_fixture(%Account{} = account, attrs) do
    attrs =
      Enum.into(attrs, %{stripe_id: "some stripe_id"})

    {:ok, customer} = Customers.create_customer(account, attrs)

    customer
  end

  def plan_fixture(), do: plan_fixture(%{})
  def plan_fixture(%Product{} = product), do: plan_fixture(product, %{})
  def plan_fixture(attrs), do: plan_fixture(product_fixture(), attrs)
  def plan_fixture(product, attrs) do
    attrs =
      Enum.into(attrs, %{
        amount: 42,
        name: "some name"
      })

    {:ok, plan} = Plans.create_plan(product, attrs)

    plan
  end

  def active_subscription_fixture(account) do
    plan = plan_fixture()
    customer = customer_fixture(account)
    attrs = %{stripe_id: unique_stripe_id(), status: "active", cancel_at: nil, current_period_end_at: ~N[2030-04-17 14:00:00]}

    subscription_fixture(plan, customer, attrs)
  end

  def inactive_subscription_fixture(account) do
    plan = plan_fixture()
    customer = customer_fixture(account)
    attrs = %{stripe_id: unique_stripe_id(), status: "active", cancel_at: nil, current_period_end_at: ~N[2010-04-17 14:00:00]}

    subscription_fixture(plan, customer, attrs)
  end

  def canceled_subscription_fixture(account) do
    plan = plan_fixture()
    customer = customer_fixture(account)
    attrs = %{stripe_id: unique_stripe_id(), status: "cancelled", cancel_at: ~N[2010-04-17 14:00:00], current_period_end_at: ~N[2030-04-17 14:00:00]}

    subscription_fixture(plan, customer, attrs)
  end

  def subscription_fixture(), do: subscription_fixture(%{})

  def subscription_fixture(attrs) do
    plan = plan_fixture()
    customer = customer_fixture()

    subscription_fixture(plan, customer, attrs)
  end

  def subscription_fixture(plan, customer, attrs) do
    attrs =
      Enum.into(attrs, %{
        cancel_at: ~N[2010-04-17 14:00:00],
        current_period_end_at: ~N[2010-04-17 14:00:00],
        status: "some status",
        stripe_id: "some stripe_id"
      })

    {:ok, subscription} = Subscriptions.create_subscription(plan, customer, attrs)

    Subscriptions.get_subscription!(subscription.id)
  end

  def invoice_fixture(), do: invoice_fixture(%{})

  def invoice_fixture(attrs) do
    customer = customer_fixture()

    invoice_fixture(customer, attrs)
  end

  def invoice_fixture(customer, attrs) do
    attrs =
      Enum.into(attrs,%{
        status: "some status",
        stripe_id: "some stripe_id",
        subtotal: 42,
        hosted_invoice_url: "some url"
      })

    {:ok, invoice} = Invoices.create_invoice(customer, attrs)

    invoice
  end
end
