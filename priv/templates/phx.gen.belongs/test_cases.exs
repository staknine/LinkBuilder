
  import <%= inspect Module.concat(context.base_module, belongs.human_plural) %>Fixtures
  import <%= inspect context.module %>Fixtures

  describe "<%= schema.plural %>" do
    alias <%= inspect schema.module %>

    @valid_attrs <%= inspect schema.params.create %>
    @update_attrs <%= inspect schema.params.update %>
    @invalid_attrs <%= inspect for {key, _} <- schema.params.create, into: %{}, do: {key, nil} %>

    setup do
      <%= belongs.singular %> = <%= belongs.singular %>_fixture()
      %{<%= belongs.singular %>: <%= belongs.singular %>}
    end

    test "list_<%= schema.plural %>/1 returns all <%= schema.plural %>", %{<%= belongs.singular %>: <%= belongs.singular %>} do
      <%= schema.singular %> = <%= schema.singular %>_fixture(<%= belongs.singular %>)
      assert <%= inspect context.alias %>.list_<%= schema.plural %>(<%= belongs.singular %>) == [<%= schema.singular %>]
    end

    test "get_<%= schema.singular %>!/1 returns the <%= schema.singular %> with given id", %{<%= belongs.singular %>: <%= belongs.singular %>} do
      <%= schema.singular %> = <%= schema.singular %>_fixture(<%= belongs.singular %>)
      assert <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= belongs.singular %>, <%= schema.singular %>.id) == <%= schema.singular %>
    end

    test "create_<%= schema.singular %>/1 with valid data creates a <%= schema.singular %>", %{<%= belongs.singular %>: <%= belongs.singular %>} do
      assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect context.alias %>.create_<%= schema.singular %>(<%= belongs.singular %>, @valid_attrs)<%= for {field, value} <- schema.params.create do %>
      assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
    end

    test "create_<%= schema.singular %>/1 with invalid data returns error changeset", %{<%= belongs.singular %>: <%= belongs.singular %>} do
      assert {:error, %Ecto.Changeset{}} = <%= inspect context.alias %>.create_<%= schema.singular %>(<%= belongs.singular %>, @invalid_attrs)
    end

    test "update_<%= schema.singular %>/2 with valid data updates the <%= schema.singular %>" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()
      assert {:ok, %<%= inspect schema.alias %>{} = <%= schema.singular %>} = <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, @update_attrs)<%= for {field, value} <- schema.params.update do %>
      assert <%= schema.singular %>.<%= field %> == <%= Mix.Phoenix.Schema.value(schema, field, value) %><% end %>
    end

    test "update_<%= schema.singular %>/2 with invalid data returns error changeset", %{<%= belongs.singular %>: <%= belongs.singular %>} do
      <%= schema.singular %> = <%= schema.singular %>_fixture(<%= belongs.singular %>)
      assert {:error, %Ecto.Changeset{}} = <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, @invalid_attrs)
      assert <%= schema.singular %> == <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= belongs.singular %>, <%= schema.singular %>.id)
    end

    test "delete_<%= schema.singular %>/1 deletes the <%= schema.singular %>", %{<%= belongs.singular %>: <%= belongs.singular %>} do
      <%= schema.singular %> = <%= schema.singular %>_fixture(<%= belongs.singular %>)
      assert {:ok, %<%= inspect schema.alias %>{}} = <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>)
      assert_raise Ecto.NoResultsError, fn -> <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= belongs.singular %>, <%= schema.singular %>.id) end
    end

    test "change_<%= schema.singular %>/1 returns a <%= schema.singular %> changeset" do
      <%= schema.singular %> = <%= schema.singular %>_fixture()
      assert %Ecto.Changeset{} = <%= inspect context.alias %>.change_<%= schema.singular %>(<%= schema.singular %>)
    end
  end
