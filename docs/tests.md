# Tests

By default, this is run as usual. So run the test with:

```elixir
mix test
```

## Browser tests with wallaby

By default, the browser tests are not run. Browser tests  requires Chromedriver to  be installed. Depending on your operating system, it can be installed in different ways.

For example:

```elixir
brew install --cask chromedriver
```

And when that is installed, run tests with the flag:

```elixir
mix test --include feature
```
