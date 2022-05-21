defmodule LinkBuilderWeb.Schema do
  use Absinthe.Schema

  alias LinkBuilderWeb.Schema

  import_types Absinthe.Type.Custom
  import_types Schema.UserTypes

  query do
    import_fields(:get_users)
    import_fields(:get_user)
  end

  mutation do
    import_fields(:login_mutation)
  end
end
