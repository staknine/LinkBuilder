# Initial Setup

## Basic Setup

Update settings with your company settings. This should be reflected in different templates
and emails.

```elixir
# config.exs

config :link_builder,
  stripe_service: Stripe,
  require_subscription: true,
  page_name: "my-app.com",
  company_name: "My App Inc",
  company_address: "26955 Fritsch Bridge",
  company_zip: "54933-7180",
  company_city: "San Fransisco",
  company_state: "California",
  company_country: "United States",
  contact_name: "John Doe",
  contact_phone: "+1 (335) 555-2036",
  contact_email: "contact@my-app.com"
```

## .env

```elixir
# .env
export STRIPE_SECRET=
export STRIPE_PUBLIC=
export STRIPE_WEBHOOK_SIGNING_KEY=
export GUARDIAN_SECRET_KEY=
export GUARDIAN_SECRET_KEY_ADMINS=
```

Generate the GUARDIAN_SECRET_KEY with:

```elixir
mix guardian.gen.secret
```

## Add administrator

Generate an administrator with the command:

```elixir
mix generate_admin email@example.com
```

And then go the login page

```elixir
http://localhost:4000/admin/sign_in
```

You can either login with the email and password or ask for a magin login
link that will be sent to the admin email.

```elixir
http://localhost:4000/admin/reset_password
```
