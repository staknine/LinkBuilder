defmodule LinkBuilderWeb.Views.NumberHelpersTest do
  use LinkBuilderWeb.ConnCase, async: true

  alias LinkBuilderWeb.Views.NumberHelpers

  describe "format_stripe_price" do
    test "returns a correctly formatted string in dollar" do
      assert NumberHelpers.format_stripe_price(%{subtotal: 900, currency: "usd"}) == "$9.00"
    end

    test "returns a correctly formatted string in pound" do
      assert NumberHelpers.format_stripe_price(%{subtotal: 9900, currency: "gbp"}) == "£99.00"
    end

    test "returns nil if subtotal and currency is not provided" do
      assert NumberHelpers.format_stripe_price(nil) == nil
      assert NumberHelpers.format_stripe_price(%{}) == nil
    end
  end
end
