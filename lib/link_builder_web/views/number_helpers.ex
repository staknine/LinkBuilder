defmodule LinkBuilderWeb.Views.NumberHelpers do
  @moduledoc """
  Convenience functions for displaying numbers und currencies.
  """

  def format_stripe_price(%{subtotal: subtotal, currency: "" <> currency}) when is_integer(subtotal) do
    currency = to_formatted_currency(currency)

    Money.new(subtotal, currency)
    |> Money.to_string()
  end

  def format_stripe_price(_), do: nil

  defp to_formatted_currency("" <> currency) do
    currency
    |> String.upcase()
    |> String.to_atom()
  end
end
