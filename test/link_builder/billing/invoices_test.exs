defmodule LinkBuilder.Billing.InvoicesTest do
  use LinkBuilder.DataCase

  import LinkBuilder.BillingFixtures

  alias LinkBuilder.Billing.Invoices
  alias LinkBuilder.Billing.Invoice

  describe "invoices" do
    test "paginate_invoices/1 returns paginated list of invoices" do
      customer = customer_fixture()
      for _ <- 1..20 do
        invoice_fixture(customer, %{stripe_id: unique_stripe_id()})
      end

      {:ok, %{invoices: invoices} = page} = Invoices.paginate_invoices(%{})

      assert length(invoices) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoices.list_invoices() == [invoice]
    end

    test "list_invoices_for_account/1 returns all invoices for an account" do
      customer = customer_fixture()
      invoice = invoice_fixture(customer, %{})
      assert Invoices.list_invoices_for_account(customer.account_id) == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice!(invoice.id) == invoice
    end

    test "get_invoice_by_stripe_id!/1 returns the invoice with given stripe_id" do
      invoice = invoice_fixture()
      assert Invoices.get_invoice_by_stripe_id!(invoice.stripe_id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      customer = customer_fixture()

      assert {:ok, %Invoice{} = invoice} =
               Invoices.create_invoice(customer, %{
                 status: "some status",
                 stripe_id: "some stripe_id",
                 subtotal: 42,
                 hosted_invoice_url: "some url"
               })

      assert invoice.status == "some status"
      assert invoice.stripe_id == "some stripe_id"
      assert invoice.subtotal == 42
      assert invoice.hosted_invoice_url == "some url"
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      customer = customer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Invoices.create_invoice(customer, %{
                 status: nil,
                 stripe_id: nil,
                 subtotal: nil,
                 hosted_invoice_url: nil
               })
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()

      assert {:ok, %Invoice{} = invoice} =
               Invoices.update_invoice(invoice, %{
                 status: "some updated status",
                 stripe_id: "some updated stripe_id",
                 subtotal: 43,
                 hosted_invoice_url: "some updated url"
               })

      assert invoice.status == "some updated status"
      assert invoice.stripe_id == "some updated stripe_id"
      assert invoice.subtotal == 43
      assert invoice.hosted_invoice_url == "some updated url"
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Invoices.update_invoice(invoice, %{
                 status: nil,
                 stripe_id: nil,
                 subtotal: nil,
                 hosted_invoice_url: nil
               })

      assert invoice == Invoices.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoices.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoices.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoices.change_invoice(invoice)
    end
  end
end
