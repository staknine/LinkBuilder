# Admin Pages

The SAAS Starter Kit comes with an admin or back office. There are already some pages setup from start.

- Dashboard
- Accounts
- Users
- Billing Products
- Billing Plans
- Billing Subscriptions
- Billing Invoices
- Admin Settings

## Account scoped pages

Some pages/resources are scoped under accounts. For example, users belongs to an account and to be
able to view users, you need to pick one of the accounts in the top menu first.

## Generate a resource for the admin page

There is a built in mix task to generate a new admin resource. It behaves basically like the ordinary
generator but it has a custom template. 

```bash
mix saas.gen.admin Todos Todo todos name description:text
```

When running the command, you will be asked if the the resource should belong to an account. That means,
it will have an `account_id` field to todos that cant be blank.

```bash
The resource you are generating could belong directly under an account.
This means that all queries will be tweaked so they are account scoped. You should
use this when you need account specific data.

Belong to an account? [Yn]
```

After the generator has run, you need to add some manual changes.

### Add routes to the router

```elixir
Add the live routes to your Admin :browser scope in lib/example_web/router.ex:

    scope "/admin", ExampleWeb.Admin, as: :admin do
      pipe_through :browser
      ...

      live "/todos", TodoLive.Index, :index
      live "/todos/new", TodoLive.Index, :new
      live "/todos/:id/edit", TodoLive.Index, :edit

      live "/todos/:id", TodoLive.Show, :show
      live "/todos/:id/show/edit", TodoLive.Show, :edit
    end
```

### Add relation in Schema File

If you decide that the new resource should belong to an account, add that in the schema file

```elixir
# lib/example/todos/todo.ex
belongs_to :account, Example.Accounts.Account
```

### Add menu in admin template

```elixir
# lib/example_web/templates/admin/layout/root.html.heex

<%= link to: Routes.admin_todo_index_path(@conn, :index) do %>
  <svg ... ></svg>
  <span>Todos</span>
<% end %>
```
