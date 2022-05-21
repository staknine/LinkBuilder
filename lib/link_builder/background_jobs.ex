defmodule LinkBuilder.BackgroundJobs do
  @moduledoc """
  The BackgroundJobs context.
  """

  import Ecto.Query, warn: false
  alias LinkBuilder.Repo

  import Saas.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias LinkBuilder.BackgroundJobs.BackgroundJob

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of jobs using filtrex
  filters.

  ## Examples

      iex> list_jobs(%{})
      %{jobs: [%BackgroundJob{}], ...}
  """
  def paginate_jobs(params \\ %{}) do
    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(:jobs), params["background_job"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_jobs(filter, params) do
      {:ok,
        %{
          jobs: page.entries,
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

  defp do_paginate_jobs(filter, params) do
    BackgroundJob
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(:jobs) do
    defconfig do
      text :state
      text :queue
      text :worker
    end
  end
end
