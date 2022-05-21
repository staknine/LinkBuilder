defmodule LinkBuilder.Billing.CustomersTest do
  use LinkBuilder.DataCase

  import LinkBuilder.BillingFixtures
  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Billing.Customers
  alias LinkBuilder.Billing.Customer

  describe "customers" do
    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_billing_customer_for_account/1 returns the customer with given id" do
      customer = customer_fixture()
      account = %LinkBuilder.Accounts.Account{id: customer.account_id}
      assert Customers.get_billing_customer_for_account(account) == customer
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer!(customer.id) == customer
    end

    test "get_customer_by_stripe_id!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Customers.get_customer_by_stripe_id!(customer.stripe_id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      account = account_fixture()
      assert {:ok, %Customer{} = customer} = Customers.create_customer(account, %{stripe_id: "some stripe_id"})
      assert customer.stripe_id == "some stripe_id"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(account, %{stripe_id: nil})
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, %{stripe_id: "some updated stripe_id"})
      assert customer.stripe_id == "some updated stripe_id"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, %{stripe_id: nil})
      assert customer == Customers.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
