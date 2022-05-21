
  import Saas.Helpers, only: [sort: 1, paginate: 4]
  import Filtrex.Type.Config

  alias <%= inspect schema.module %>

  @pagination [page_size: 15]
  @pagination_distance 5

  @doc """
  Paginate the list of <%= schema.plural %> using filtrex
  filters.

  ## Examples

      iex> paginate_<%= schema.plural %>(account, %{})
      %{<%= schema.plural %>: [%<%= inspect schema.alias %>{}], ...}
  """
  def paginate_<%= schema.plural %>(account, params \\ %{}) do
    Repo.put_account_id(account.id)

    params =
      params
      |> Map.put_new("sort_direction", "desc")
      |> Map.put_new("sort_field", "inserted_at")

    {:ok, sort_direction} = Map.fetch(params, "sort_direction")
    {:ok, sort_field} = Map.fetch(params, "sort_field")

    with {:ok, filter} <- Filtrex.parse_params(filter_config(<%= inspect String.to_atom(schema.plural) %>), params["<%= schema.singular %>"] || %{}),
         %Scrivener.Page{} = page <- do_paginate_<%= schema.plural %>(filter, params) do
      {:ok,
        %{
          <%= schema.plural %>: page.entries,
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

  defp do_paginate_<%= schema.plural %>(filter, params) do
    <%= inspect schema.alias %>
    |> Filtrex.query(filter)
    |> order_by(^sort(params))
    |> paginate(Repo, params, @pagination)
  end

  defp filter_config(<%= inspect String.to_atom(schema.plural) %>) do
    defconfig do
      <%= for {name, type} <- schema.attrs do %><%= cond do %>
        <% type in [:string, :text] -> %>text <%= inspect name %>
        <% type in [:integer, :number] -> %>number <%= inspect name %>
        <% type in [:naive_datetime, :utc_datetime, :datetime, :date] -> %>date <%= inspect name %>
        <% type in [:boolean] -> %>boolean <%= inspect name %>
        <% true -> %>
      <% end %><% end %>
    end
  end

  @doc """
  Returns the list of <%= schema.plural %> for an account.

  ## Examples

      iex> list_<%= schema.plural %>(account)
      [%<%= inspect schema.alias %>{}, ...]

  """
  def list_<%= schema.plural %>(account) do
    Repo.all(<%= inspect schema.alias %>, account_id: account.id)
  end

  @doc """
  Gets a single <%= schema.singular %>.

  Raises `Ecto.NoResultsError` if the <%= schema.human_singular %> does not exist.

  ## Examples

      iex> get_<%= schema.singular %>!(account, 123)
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>!(account, 456)
      ** (Ecto.NoResultsError)

  """
  def get_<%= schema.singular %>!(account, id), do: Repo.get!(<%= inspect schema.alias %>, id, account_id: account.id)

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> create_<%= schema.singular %>(account, %{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> create_<%= schema.singular %>(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_<%= schema.singular %>(account, attrs \\ %{}) do
    # account
    # |> Ecto.build_assoc(:<%= schema.plural %>)
    # |> <%= inspect schema.alias %>.changeset(attrs)
    # |> Repo.insert()
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:account, account)
    |> Repo.insert()
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> update_<%= schema.singular %>(<%= schema.singular %>, %{field: new_value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> update_<%= schema.singular %>(<%= schema.singular %>, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a <%= schema.singular %>.

  ## Examples

      iex> delete_<%= schema.singular %>(<%= schema.singular %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> delete_<%= schema.singular %>(<%= schema.singular %>)
      {:error, %Ecto.Changeset{}}

  """
  def delete_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    Repo.delete(<%= schema.singular %>)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking <%= schema.singular %> changes.

  ## Examples

      iex> change_<%= schema.singular %>(<%= schema.singular %>)
      %Ecto.Changeset{data: %<%= inspect schema.alias %>{}}

  """
  def change_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs \\ %{}) do
    <%= inspect schema.alias %>.changeset(<%= schema.singular %>, attrs)
  end
