defmodule LinkBuilder.Billing.CreateStripeCustomerTest do
  use LinkBuilder.DataCase
  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Accounts
  alias LinkBuilder.Billing.Customers
  alias LinkBuilder.Billing.CreateStripeCustomer

  describe "creating a stripe customer and billing customer" do
    test "creates a billing customer after broadcasting it" do
      %{id: id} = account = account_fixture(%{
        users: %{
          zero: %{
            email: unique_user_email(),
            password: "super-secret-123",
            password_confirmation: "super-secret-123"
          }
        }
      })

      start_supervised(CreateStripeCustomer, [])
      CreateStripeCustomer.subscribe()

      Accounts.notify_subscribers({:ok, account})

      assert_receive {:customer, _}
      assert [%{account_id: ^id, stripe_id: "" <> _}] = Customers.list_customers()
    end
  end
end
