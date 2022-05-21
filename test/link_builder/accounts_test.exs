defmodule LinkBuilder.AccountsTest do
  use LinkBuilder.DataCase

  import LinkBuilder.AccountsFixtures

  alias LinkBuilder.Accounts
  alias LinkBuilder.Accounts.User

  def setup_account(_) do
    account = account_fixture()
    {:ok, account: account}
  end

  describe "accounts" do
    alias LinkBuilder.Accounts.Account

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "paginate_accounts/1 returns paginated list of accounts" do
      for _ <- 1..20 do
        account_fixture()
      end

      {:ok, %{accounts: accounts} = page} = Accounts.paginate_accounts(%{})

      assert length(accounts) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
      assert account.name == "some name"
      assert "" <> _ = account.token
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "when the account is created it creates a stripe_customer and billing_customer" do
      Accounts.subscribe_on_account_created()

      valid_attrs = %{
        "name" => "Awesome App",
        "users" => %{
          "0" => %{
            "email" => unique_user_email(),
            "password" => "super-secret-123",
            "password_confirmation" => "super-secret-123"
          }
        }
      }

      {:ok, account} = Accounts.create_account(valid_attrs)

      assert_received(%{account: ^account})
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end

    test "change_account_registration/1 returns a account changeset" do
      assert %Ecto.Changeset{} = Accounts.change_account_registration(%Account{})
    end
  end

  describe "list_users/1" do
    setup [:setup_account]

    test "list_users/0 returns all users", %{account: account} do
      user = user_fixture(account)
      assert Accounts.list_users(account) == [user]
    end
  end

  describe "get_user!/2" do
    setup [:setup_account]

    test "raises if id is invalid", %{account: account} do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(account, "7d7cfd8a-7799-4f3e-bad7-4db3af3234f4")
      end
    end

    test "returns the user with the given id", %{account: account} do
      %{id: id} = user = user_fixture(account)
      assert %User{id: ^id} = Accounts.get_user!(account, user.id)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "with_account/1" do
    test "with_account/1 loads the account for a specific user" do
      user = user_fixture()
      assert %User{account: %Accounts.Account{}} = Accounts.with_account(user)
    end

    test "with_account/1 loads the account for a list of users" do
      user = user_fixture()
      assert [%User{account: %Accounts.Account{}}] = Accounts.with_account([user])
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_with_account_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = user_fixture()

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Accounts.get_user!(user.account, user.id).email != email
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "short",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{
          password: valid_user_password(),
          password_confirmation: valid_user_password()
        })

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user} do
      {:ok, user} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password",
          password_confirmation: "new valid password"
        })

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end
  end
end
