defmodule LinkBuilder.Billing.Invoices do
  @moduledoc """
  The Billing Invoices context.
  """

  import Ecto.Query, warn: false
  import Saas.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  @pagination [page_size: 15]
  @pagination_distance 5

  alias LinkBuilder.Repo
  alias LinkBuilder.Billing.Invoice

  @doc """
  Paginate the list of invoices using filtrex
  filters.

  ## Examples

      iex> paginate_invoices(%{})
      %{invoices: [%Invoice{}], ...}
  """
  def paginate_invoices(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:invoices), params["invoice"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_invoices(filter, params) do
      {:ok,
        %{
          invoices: page.entries,
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

  defp do_paginate_invoices(filter, params) do
    Invoice
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:invoices) do
    defconfig do
      text :stripe_id
      text :stripe_invoice_name
    end
  end

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  @doc """
  Returns the list of invoices for an account.

  ## Examples

      iex> list_invoices_for_account(account_id)
      [%Invoice{}, ...]

  """
  def list_invoices_for_account(account_id) do
    from(i in Invoice,
      join: c in assoc(i, :customer),
      where: c.account_id == ^account_id,
      order_by: [desc: :inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  @doc """
  Gets a single Invoice by Stripe Id.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice_by_stripe_id!(123)
      %Subscription{}

      iex> get_invoice_by_stripe_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice_by_stripe_id!(stripe_id), do: Repo.get_by!(Invoice, stripe_id: stripe_id)

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(customer, %{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(customer, attrs \\ %{}) do
    customer
    |> Ecto.build_assoc(:invoices)
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end
end
