defmodule LinkBuilder.Billing.HandleInvoicesTest do
  use LinkBuilder.DataCase

  import LinkBuilder.BillingFixtures

  alias LinkBuilder.Billing.Invoice
  alias LinkBuilder.Billing.Invoices
  alias LinkBuilder.Billing.HandleInvoices

  describe "create_invoice" do
    setup [:setup_customer]

    test "create_or_update_invoice/1 creates a invoice", %{customer: customer} do
      %{id: stripe_id} = stripe_invoice = invoice_data(%{customer: customer.stripe_id})

      HandleInvoices.create_or_update_invoice(stripe_invoice)

      assert [%Invoice{stripe_id: ^stripe_id} = invoice] = Invoices.list_invoices()
      assert invoice.subtotal == 900
      assert invoice.status == "paid"
      assert invoice.customer_id == customer.id
    end
  end

  describe "update invoice" do
    setup [:setup_invoice]

    test "create_or_update_invoice/1 cancels a invoice", %{invoice: invoice} do
      stripe_invoice =
        invoice_data(%{
          id: invoice.stripe_id,
          status: "canceled"
        })

      assert [%Invoice{status: "paid"}] = Invoices.list_invoices()
      HandleInvoices.create_or_update_invoice(stripe_invoice)

      assert [%Invoice{status: "canceled"}] = Invoices.list_invoices()
    end
  end

  defp setup_customer(_) do
    customer = customer_fixture(%{stripe_id: unique_stripe_id()})
    %{customer: customer}
  end

  defp setup_invoice(_) do
    invoice = invoice_fixture(%{status: "paid"})
    %{invoice: invoice}
  end

  defp invoice_data(attrs) do
    %Stripe.Invoice{
      id: unique_stripe_id(),
      customer: unique_stripe_id(),
      currency: "usd",
      subtotal: 900,
      status: "paid",
      invoice_pdf:
        "https://pay.stripe.com/invoice/#{unique_stripe_id()}/#{unique_stripe_id()}/pdf",
      hosted_invoice_url:
        "https://invoice.stripe.com/i/#{unique_stripe_id()}/#{unique_stripe_id()}"
    }
    |> Map.merge(attrs)
  end
end
