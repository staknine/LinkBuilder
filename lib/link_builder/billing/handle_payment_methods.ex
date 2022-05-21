defmodule LinkBuilder.Billing.HandlePaymentMethods do
  alias LinkBuilder.Accounts
  alias LinkBuilder.Billing.Customers

  defdelegate get_customer_by_stripe_id!(customer_stripe_id), to: Customers
  defdelegate get_account!(account_id), to: Accounts

  def add_card_info(%{customer: customer_stripe_id, card: card}) do
    %{account_id: account_id} = get_customer_by_stripe_id!(customer_stripe_id)
    account = get_account!(account_id)

    Accounts.update_account(account, %{
      card_brand: card.brand,
      card_last4: card.last4,
      card_exp_year: card.exp_year,
      card_exp_month: card.exp_month
    })
  end

  def remove_card_info(%{customer: customer_stripe_id}) do
    %{account_id: account_id} = get_customer_by_stripe_id!(customer_stripe_id)
    account = get_account!(account_id)

    Accounts.update_account(account, %{
      card_brand: nil,
      card_last4: nil,
      card_exp_year: nil,
      card_exp_month: nil
    })
  end
end
