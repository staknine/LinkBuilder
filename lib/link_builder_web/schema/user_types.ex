defmodule LinkBuilderWeb.Schema.UserTypes do
  use Absinthe.Schema.Notation

  alias LinkBuilderWeb.Resolvers

  @desc "A user"
  object :user do
    field :email, :string
    field :id, :id
  end

  object :get_users do
    @desc """
    Get a list of users
    """

    field :users, list_of(:user) do
      resolve(&Resolvers.Accounts.list_users/2)
    end
  end

  object :get_user do
    @desc """
    Get a specific user
    """

    field :user, :user do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Accounts.get_user/2)
    end
  end

  object :login_mutation do
    @desc """
    login with the params
    """

    field :create_session, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&Resolvers.Accounts.login/2)
    end
  end

  @desc "session value"
  object :session do
    field(:token, :string)
    field(:user, :user)
  end
end
