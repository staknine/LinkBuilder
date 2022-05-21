defmodule <%= inspect context.module %>Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `<%= schema.singular %>` context.
  """

  import <%= inspect Module.concat(context.base_module, belongs.human_plural) %>Fixtures

  alias <%= inspect context.module %>
  alias <%= inspect belongs.module %>

  @valid_<%= schema.singular %>_attrs <%= inspect schema.params.create %>

  def <%= schema.singular %>_fixture(), do: <%= schema.singular %>_fixture(%{})
  def <%= schema.singular %>_fixture(%<%= inspect belongs.alias %>{} = account), do: <%= schema.singular %>_fixture(<%= belongs.singular %>, %{})

  def <%= schema.singular %>_fixture(attrs) do
    <%= belongs.singular %> = <%= belongs.singular %>_fixture()
    <%= schema.singular %>_fixture(<%= belongs.singular %>, attrs)
  end

  def <%= schema.singular %>_fixture(%<%= inspect belongs.alias %>{} = <%= belongs.singular %>, attrs) do
    attrs =
      Enum.into(attrs, @valid_<%= schema.singular %>_attrs)

    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(<%= belongs.singular %>, attrs)

    <%= schema.singular %>
  end
end
