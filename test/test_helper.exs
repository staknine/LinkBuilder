ExUnit.configure(exclude: :feature)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(LinkBuilder.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, LinkBuilderWeb.Endpoint.url)
