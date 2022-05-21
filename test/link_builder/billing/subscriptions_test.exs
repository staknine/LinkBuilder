defmodule LinkBuilder.Billing.SubscriptionsTest do
  use LinkBuilder.DataCase

  import LinkBuilder.BillingFixtures
  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Billing.Subscriptions
  alias LinkBuilder.Billing.Subscription

  describe "subscriptions" do
    test "paginate_subscriptions/1 returns paginated list of subscriptions" do
      plan = plan_fixture()
      customer = customer_fixture()

      for _ <- 1..20 do
        subscription_fixture(plan, customer, %{stripe_id: unique_stripe_id()})
      end

      {:ok, %{subscriptions: subscriptions} = page} = Subscriptions.paginate_subscriptions(%{})

      assert length(subscriptions) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_subscriptions/0 returns all subscriptions" do
      subscription = subscription_fixture()
      assert Subscriptions.list_subscriptions() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Subscriptions.get_subscription!(subscription.id) == subscription
    end

    test "get_subscription_by_stripe_id!/1 returns the subscription with given stripe_id" do
      subscription = subscription_fixture()
      assert Subscriptions.get_subscription_by_stripe_id!(subscription.stripe_id) == subscription
    end

    test "get_active_subscription_for_account/1 with active subscription returns the subscription for given account" do
      account = account_fixture()
      %{id: id} = active_subscription_fixture(account)

      assert %Subscription{id: ^id} = Subscriptions.get_active_subscription_for_account(account.id)
    end

    test "get_active_subscription_for_account/1 with inactive subscription returns nil for given account" do
      account = account_fixture()

      assert %{id: _id} = inactive_subscription_fixture(account)
      assert Subscriptions.get_active_subscription_for_account(account.id) == nil
    end

    test "get_active_subscription_for_account/1 with canceled subscription returns nil for given account" do
      account = account_fixture()

      assert %{id: _id} = canceled_subscription_fixture(account)
      assert Subscriptions.get_active_subscription_for_account(account.id) == nil
    end

    test "create_subscription/1 with valid data creates a subscription" do
      plan = plan_fixture()
      customer = customer_fixture()

      create_attrs = %{cancel_at: ~N[2010-04-17 14:00:00], current_period_end_at: ~N[2010-04-17 14:00:00], status: "some status", stripe_id: "some stripe_id"}
      assert {:ok, %Subscription{} = subscription} = Subscriptions.create_subscription(plan, customer, create_attrs)
      assert subscription.cancel_at == ~N[2010-04-17 14:00:00]
      assert subscription.current_period_end_at == ~N[2010-04-17 14:00:00]
      assert subscription.status == "some status"
      assert subscription.stripe_id == "some stripe_id"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      plan = plan_fixture()
      customer = customer_fixture()

      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscription(plan, customer, %{status: nil, stripe_id: nil})
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()
      update_attrs = %{cancel_at: ~N[2011-05-18 15:01:01], current_period_end_at: ~N[2011-05-18 15:01:01], status: "some updated status", stripe_id: "some updated stripe_id"}
      assert {:ok, %Subscription{} = subscription} = Subscriptions.update_subscription(subscription, update_attrs)
      assert subscription.cancel_at == ~N[2011-05-18 15:01:01]
      assert subscription.current_period_end_at == ~N[2011-05-18 15:01:01]
      assert subscription.status == "some updated status"
      assert subscription.stripe_id == "some updated stripe_id"
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscriptions.update_subscription(subscription, %{status: nil, stripe_id: nil})
      assert subscription == Subscriptions.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Subscriptions.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_subscription(subscription)
    end
  end
end
