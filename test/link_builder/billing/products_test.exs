defmodule LinkBuilder.Billing.ProductsTest do
  use LinkBuilder.DataCase

  import LinkBuilder.BillingFixtures

  alias LinkBuilder.Billing.Products
  alias LinkBuilder.Billing.Product

  @valid_product_attrs %{name: "some name"}
  @update_product_attrs %{name: "some updated name"}
  @invalid_product_attrs %{name: nil}

  describe "products" do
    test "paginate_products/1 returns paginated list of products" do
      for _ <- 1..20 do
        product_fixture(%{stripe_id: unique_stripe_id()})
      end

      {:ok, %{products: products} = page} = Products.paginate_products(%{})

      assert length(products) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "get_product_by_stripe_id!/1 returns the product with given stripe_id" do
      product = product_fixture()
      assert Products.get_product_by_stripe_id!(product.stripe_id) == product
    end

    test "with_plans/1 loads the plans for a specific product" do
      product = product_fixture()
      assert %Product{plans: []} = Products.with_plans(product)
    end

    test "with_plans/1 loads the plans for a list of products" do
      product = product_fixture()
      assert [%Product{plans: []}] = Products.with_plans([product])
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Products.create_product(@valid_product_attrs)
      assert "prod_" <> _ = product.stripe_id
      assert product.name == "some name"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_product_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, %Product{} = product} = Products.update_product(product, @update_product_attrs)
      assert product.name == "some updated name"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_product_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Products.change_product(product)
    end
  end
end
