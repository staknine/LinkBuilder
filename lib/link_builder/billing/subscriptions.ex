defmodule LinkBuilder.Billing.Subscriptions do
  @moduledoc """
  The Billing Subscriptions context.
  """

  import Ecto.Query, warn: false
  import Saas.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  alias LinkBuilder.Repo
  alias LinkBuilder.Billing.Subscription

  @doc """
  Paginate the list of subscriptions using filtrex
  filters.

  ## Examples

      iex> paginate_subscriptions(%{})
      %{subscriptions: [%Subscription{}], ...}
  """
  def paginate_subscriptions(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:subscriptions), params["subscription"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_subscriptions(filter, params) do
      {:ok,
        %{
          subscriptions: with_plan_and_account(page.entries),
          page_number: page.page_number,
          page_size: page.page_size,
          total_pages: page.total_pages,
          total_entries: page.total_entries,
          distance: @pagination_distance,
          sort_field: sort_field,
          sort_direction: sort_direction
        }
      }
    else
      {:error, error} -> {:error, error}
      error -> {:error, error}
    end
  end

  # JUMP THROUGH SOME HOOPS TO GET SORTING ON ASSOCIATIONS WORKING.
  defp do_paginate_subscriptions(filter, params) do
    {direction, field_name} = sort(params)

    named_binding =
      cond do
        field_name in [:plan_name] -> :plans
        field_name in [:account_name] -> :accounts
        true -> :subscriptions
      end

    field_name =
      cond do
        field_name in [:account_name, :plan_name] -> :name
        true -> field_name
      end

    from(
      s in Subscription, as: :subscriptions,
      join: p in assoc(s, :plan), as: :plans,
      join: c in assoc(s, :customer), as: :customers,
      join: a in assoc(c, :account), as: :accounts
    )
    |> Filtrex.query(filter)
    |> sorting_associtated_fields(named_binding, direction, field_name)
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:subscriptions) do
    defconfig do
      text :stripe_id
      text :stripe_subscription_name
    end
  end

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscription)
  end

  def with_plan_and_account(subscription_or_subscriptions) do
    subscription_or_subscriptions
    |> Repo.preload([:plan, :customer, :account], skip_account_id: true)
  end

  def list_subs do
    from(
      s in Subscription,
      join: p in assoc(s, :plan), as: :plans,
      join: c in assoc(s, :customer),
      join: a in assoc(c, :account)
    )
    |> Repo.all(skip_account_id: true)
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription!(id), do: Repo.get!(Subscription, id)

  @doc """
  Gets a single subscription by Stripe Id.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription_by_stripe_id!(123)
      %Subscription{}

      iex> get_subscription_by_stripe_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_by_stripe_id!(stripe_id), do: Repo.get_by!(Subscription, stripe_id: stripe_id)

  @doc """
  Gets a single active subscription for a account_id.

  Returns `nil` if an active Subscription does not exist.

  ## Examples

      iex> get_active_subscription_for_account(123)
      %Subscription{}

      iex> get_active_subscription_for_account(456)
      nil

  """
  def get_active_subscription_for_account(account_id) do
    from(s in Subscription,
      join: c in assoc(s, :customer),
      where: c.account_id == ^account_id,
      where: is_nil(s.cancel_at) or s.cancel_at > ^NaiveDateTime.utc_now(),
      where: s.current_period_end_at > ^NaiveDateTime.utc_now(),
      where: s.status == "active",
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(plan, customer, attrs \\ %{}) do
    plan
    |> Ecto.build_assoc(:subscriptions)
    |> Subscription.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:customer, customer)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end

  defp sorting_associtated_fields(query, named_binding, direction, field_name) do
    from([{^named_binding, a}] in query, order_by: {^direction, field(a, ^field_name)})
  end
end
