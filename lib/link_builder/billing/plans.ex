defmodule LinkBuilder.Billing.Plans do
  @moduledoc """
  The Billing Plans context.
  """

  import Ecto.Query, warn: false
  import Saas.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @stripe_service Application.get_env(:link_builder, :stripe_service)

  @pagination [page_size: 15]
  @pagination_distance 5

  alias LinkBuilder.Repo
  alias LinkBuilder.Billing.Plan

  @doc """
  Paginate the list of products using filtrex
  filters.

  ## Examples

      iex> paginate_plans(%{})
      %{plans: [%Plan{}], ...}
  """
  def paginate_plans(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:plans), params["plan"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_plans(filter, params) do
      {:ok,
        %{
          plans: with_product(page.entries),
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

  defp do_paginate_plans(filter, params) do
    Plan
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:plans) do
    defconfig do
      text :stripe_id
      text :name
      number :amount
      text :currency
      text :interval
      boolean :active
    end
  end

  @doc """
  Returns the list of plans.

  ## Examples

      iex> list_plans()
      [%Plan{}, ...]

  """
  def list_plans do
    Repo.all(Plan)
  end

  @doc """
  Gets a single plan.

  Raises `Ecto.NoResultsError` if the Plan does not exist.

  ## Examples

      iex> get_plan!(123)
      %Plan{}

      iex> get_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plan!(id), do: Repo.get!(Plan, id)

  @doc """
  Gets a single plan by Stripe Id.

  Raises `Ecto.NoResultsError` if the Plan does not exist.

  ## Examples

      iex> get_plan_by_stripe_id!(123)
      %Plan{}

      iex> get_plan_by_stripe_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plan_by_stripe_id!(stripe_id), do: Repo.get_by!(Plan, stripe_id: stripe_id)

  @doc """
  Preload product for a plan or a list of plans.

  ## Examples

      iex> with_product(%Product{})
      %Product{plans: [%Plan{}]}

  """
  def with_product(plan_or_plans) do
    plan_or_plans
    |> Repo.preload(:product)
  end

  @doc """
  Creates a plan.

  ## Examples

      iex> create_plan(product, %{field: value})
      {:ok, %Plan{}}

      iex> create_plan(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plan(product, attrs \\ %{}) do
    product
    |> Ecto.build_assoc(:plans)
    |> Plan.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %Plan{} = plan} -> create_plan_in_stripe(product, plan)
      result -> result
    end
  end

  @doc """
  Updates a plan.

  ## Examples

      iex> update_plan(plan, %{field: new_value})
      {:ok, %Plan{}}

      iex> update_plan(plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plan(%Plan{} = plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, %Plan{} = plan} -> update_plan_in_stripe(plan, %{name: plan.name})
      result -> result
    end
  end

  @doc """
  Deletes a plan.

  ## Examples

      iex> delete_plan(plan)
      {:ok, %Plan{}}

      iex> delete_plan(plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plan(%Plan{} = plan) do
    update_plan_in_stripe(plan, %{active: false})
    Repo.delete(plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plan changes.

  ## Examples

      iex> change_plan(plan)
      %Ecto.Changeset{data: %Plan{}}

  """
  def change_plan(%Plan{} = plan, attrs \\ %{}) do
    Plan.changeset(plan, attrs)
  end

  @doc """
  Returns the list of plans with produt name.

  ## Examples

      iex> list_plans_for_subscription_page()
      [%Plan{}, ...]

  """
  def list_plans_for_subscription_page do
    from(
      p in Plan,
      join: pp in assoc(p, :product),
      where: not is_nil(p.stripe_id),
      select: %{period: p.name, name: pp.name, stripe_id: p.stripe_id, id: p.id, amount: p.amount},
      order_by: [p.amount, p.name]
    )
    |> Repo.all()
  end

  defp create_plan_in_stripe(_product, %{stripe_id: "" <> _} = plan), do: {:ok, plan}
  defp create_plan_in_stripe(%{stripe_id: nil} = _product, plan), do: {:ok, plan}
  defp create_plan_in_stripe(product, plan) do
    case @stripe_service.Plan.create(%{product: product.stripe_id, name: plan.name}) do
      {:ok, %{id: stripe_id}} -> update_plan(plan, %{stripe_id: stripe_id})
      _result -> plan
    end
  end

  defp update_plan_in_stripe(plan, attrs) do
    @stripe_service.Plan.update(plan.stripe_id, attrs)
    {:ok, plan}
  end
end
