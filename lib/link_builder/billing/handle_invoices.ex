defmodule LinkBuilder.Billing.HandleInvoices do
  alias LinkBuilder.Billing.Invoices
  alias LinkBuilder.Billing.Customers

  defdelegate get_customer_by_stripe_id!(customer_stripe_id), to: Customers
  defdelegate get_invoice_by_stripe_id!(invoice_stripe_id), to: Invoices

  def create_or_update_invoice(%{customer: customer_stripe_id, id: stripe_id} = stripe_invoice) do
    stripe_invoice = Map.from_struct(stripe_invoice)

    try do
      get_invoice_by_stripe_id!(stripe_id)
      |> Invoices.update_invoice(stripe_invoice)
    rescue
      Ecto.NoResultsError ->
        customer = get_customer_by_stripe_id!(customer_stripe_id)
        Invoices.create_invoice(customer, Map.put(stripe_invoice, :stripe_id, stripe_id))
    end
  end
end
