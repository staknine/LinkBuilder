defmodule <%= inspect context.module %>Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `<%= schema.singular %>` context.
  """

  alias <%= inspect context.module %>

  @valid_<%= schema.singular %>_attrs <%= inspect schema.params.create %>

  def <%= schema.singular %>_fixture(), do: <%= schema.singular %>_fixture(%{})

  def <%= schema.singular %>_fixture(attrs) do
    attrs =
      Enum.into(attrs, @valid_<%= schema.singular %>_attrs)

    {:ok, <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(attrs)

    <%= schema.singular %>
  end
end
