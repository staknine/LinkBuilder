defmodule LinkBuilderWeb.Admin.ProductLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest
  import LinkBuilder.BillingFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_product]

    test "lists all products", %{conn: conn, product: product} do
      {:ok, _index_live, html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert html =~ "Listing Products"
      assert html =~ product.stripe_id
    end

    test "saves new product", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert index_live |> element("a[href=\"/admin/products/new\"]") |> render_click() =~
               "New Product"

      assert_patch(index_live, Routes.admin_product_index_path(conn, :new))

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#product-form", product: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_product_index_path(conn, :index))

      assert html =~ "Product created successfully"
    end

    test "updates product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, Routes.admin_product_index_path(conn, :index))

      assert index_live |> element("#product-#{product.id} a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(index_live, Routes.admin_product_index_path(conn, :edit, product))

      assert index_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#product-form", product: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_product_index_path(conn, :index))

      assert html =~ "Product updated successfully"
    end

    test "archives product in listing", %{conn: conn, product: product} do
      {:ok, index_live, _html} = live(conn, Routes.admin_product_index_path(conn, :index))

      html = index_live |> element("#product-#{product.id} a", "Archive") |> render_click()

      assert html =~ "Activate"
      assert html =~ "Archived"
    end
  end

  describe "Show" do
    setup [:create_product]

    test "displays product", %{conn: conn, product: product} do
      {:ok, _show_live, html} = live(conn, Routes.admin_product_show_path(conn, :show, product))

      assert html =~ "Show Product"
      assert html =~ product.stripe_id
    end

    test "updates product within modal", %{conn: conn, product: product} do
      {:ok, show_live, _html} = live(conn, Routes.admin_product_show_path(conn, :show, product))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Product"

      assert_patch(show_live, Routes.admin_product_show_path(conn, :edit, product))

      assert show_live
             |> form("#product-form", product: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#product-form", product: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_product_show_path(conn, :show, product))

      assert html =~ "Product updated successfully"
    end
  end
end
