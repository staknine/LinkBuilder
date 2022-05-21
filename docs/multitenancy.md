# Multi Tenancy

The basic idea with the SAAS Starter Kit is that you will make a multi account app.
And each account can have many users. Also, everything that is isolated between accounts
can have an account_id field.

If it has that, Ecto Repo will fail if you don't add an account_id as an argument to
your query. This will prevent to show one accounts data to another account.

This could either be done with adding the account_id in a queries where clause:

```elixir
Repo.get!(User, id, account_id: account.id)
```

Or adding the account_id to the current Repo process

```elixir
Repo.put_account_id(account.id)
Repo.get!(User, id)
```
