defmodule LinkBuilder.Billing.Products do
  @moduledoc """
  The Billing Products context.
  """

  import Ecto.Query, warn: false
  import Saas.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @stripe_service Application.get_env(:link_builder, :stripe_service)

  @pagination [page_size: 15]
  @pagination_distance 5

  alias LinkBuilder.Repo
  alias LinkBuilder.Billing.Product

  @doc """
  Paginate the list of products using filtrex
  filters.

  ## Examples

      iex> paginate_products(%{})
      %{products: [%Product{}], ...}
  """
  def paginate_products(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:products), params["product"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_products(filter, params) do
      {:ok,
        %{
          products: page.entries,
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

  defp do_paginate_products(filter, params) do
    Product
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:products) do
    defconfig do
      text :stripe_id
      text :name
      boolean :active
    end
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Gets a single product by stripe_id.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product_by_stripe_id!("prod_IBuHQ")
      %Product{}

      iex> get_product!("prod_xxx")
      ** (Ecto.NoResultsError)

  """
  def get_product_by_stripe_id!(stripe_id), do: Repo.get_by!(Product, stripe_id: stripe_id)

  @doc """
  Preload plans for a product or a list of products.

  ## Examples

      iex> with_plans(%Product{})
      %Product{plans: [%Plan{}]}

  """
  def with_plans(product_or_products) do
    product_or_products
    |> Repo.preload(:plans)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, %Product{} = product} -> create_product_in_stripe(product)
      result -> result
    end
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, %Product{} = product} -> update_product_in_stripe(product, %{name: product.name})
      result -> result
    end
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    update_product_in_stripe(product, %{active: false})
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  defp create_product_in_stripe(%{stripe_id: "" <> _} = product), do: {:ok, product}
  defp create_product_in_stripe(product) do
    case @stripe_service.Product.create(%{name: product.name}) do
      {:ok, %{id: stripe_id}} -> update_product(product, %{stripe_id: stripe_id})
      _result -> product
    end
  end

  defp update_product_in_stripe(product, attrs) do
    @stripe_service.Product.update(product.stripe_id, attrs)
    {:ok, product}
  end
end
