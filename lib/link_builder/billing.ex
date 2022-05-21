defmodule LinkBuilder.Billing do
  @moduledoc """
  The Billing context and contains the billing functions that are
  available outside of billing.
  """

  alias LinkBuilder.Billing.Products
  alias LinkBuilder.Billing.Plans
  alias LinkBuilder.Billing.Customers
  alias LinkBuilder.Billing.Subscriptions
  alias LinkBuilder.Billing.Invoices

  defdelegate list_products(), to: Products
  defdelegate with_plans(product_or_products), to: Products
  defdelegate create_product(attrs), to: Products
  defdelegate paginate_products(attrs), to: Products
  defdelegate get_product!(id), to: Products
  defdelegate delete_product(id), to: Products
  defdelegate change_product(product, attrs \\ %{}), to: Products
  defdelegate update_product(product, attrs), to: Products

  defdelegate get_plan!(plan_id), to: Plans
  defdelegate create_plan(product, attrs), to: Plans
  defdelegate list_plans_for_subscription_page, to: Plans
  defdelegate paginate_plans(attrs), to: Plans
  defdelegate delete_plan(id), to: Plans
  defdelegate change_plan(plan, attrs \\ %{}), to: Plans
  defdelegate update_plan(plan, attrs), to: Plans
  defdelegate with_product(plan), to: Plans

  defdelegate get_billing_customer_for_account(account), to: Customers

  defdelegate get_active_subscription_for_account(id), to: Subscriptions
  defdelegate paginate_subscriptions(attrs), to: Subscriptions
  defdelegate get_subscription!(id), to: Subscriptions
  defdelegate delete_subscription(id), to: Subscriptions
  defdelegate change_subscription(subscription, attrs \\ %{}), to: Subscriptions
  defdelegate update_subscription(subscription, attrs), to: Subscriptions

  defdelegate list_invoices_for_account(account_id), to: Invoices
  defdelegate paginate_invoices(attrs), to: Invoices
  defdelegate get_invoice!(id), to: Invoices
  defdelegate delete_invoice(id), to: Invoices
  defdelegate change_invoice(invoice, attrs \\ %{}), to: Invoices
  defdelegate update_invoice(invoice, attrs), to: Invoices

  def stripe_enabled? do
    is_nil(Application.get_env(:stripity_stripe, :api_key)) == false
  end
end
