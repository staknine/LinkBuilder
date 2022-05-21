defmodule LinkBuilderWeb.PricingLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest
  import MockStripe, only: [token: 0]

  alias LinkBuilder.Billing

  describe "Pricing page" do
    setup [:setup_products_and_plans]

    test "disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/pricing")
      assert disconnected_html =~ "Plans &amp; Pricing"
      assert render(page_live) =~ "Plans &amp; Pricing"
    end

    test "displays both products", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing")

      assert render(view) =~ "Standard Plan"
      assert render(view) =~ "Premium Plan"
    end

    test "default price_interval is month", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing")

      assert render(view) =~ "$9"
      assert render(view) =~ "$19"
      assert render(view) =~ "per month"
    end

    test "click Bill Yearly switches to yearly prices", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing")
      assert view |> element("button", "Yearly") |> render_click()
      assert render(view) =~ "$99"
      assert render(view) =~ "$199"
      assert render(view) =~ "per year"
    end
  end

  def setup_products_and_plans(_) do
    products_data()
    |> Enum.each(fn %{
                      stripe_id: stripe_id,
                      name: name,
                      plans: plans
                    } ->
      {:ok, product} =
        Billing.create_product(%{stripe_id: stripe_id, name: name})

      plans
      |> Enum.each(fn plan_attrs ->
        Billing.create_plan(product, plan_attrs)
      end)
    end)

    :ok
  end

  defp products_data do
    [
      %{
        plans: [
          %{
            amount: 9900,
            stripe_id: "price_#{token()}",
            name: "year"
          },
          %{
            amount: 900,
            stripe_id: "price_#{token()}",
            name: "month"
          }
        ],
        stripe_id: "prod_#{token()}",
        name: "Standard Plan"
      },
      %{
        plans: [
          %{
            amount: 1900,
            stripe_id: "price_#{token()}",
            name: "month"
          },
          %{
            amount: 19900,
            stripe_id: "price_#{token()}",
            name: "year"
          }
        ],
        stripe_id: "prod_#{token()}",
        name: "Premium Plan"
      }
    ]
  end
end
