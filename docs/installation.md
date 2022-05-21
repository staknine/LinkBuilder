# Installation

After you have downloaded the package, go into it and run:

```elixir
mix deps.get
```

Setup the database and run the migrations with:

```elixir
mix ecto.create && mix ecto.migrate
```

Install assets with

```elixir
cd assets && yarn install
```

Create the default .env file

```elixir
cp .env.example .env
```
