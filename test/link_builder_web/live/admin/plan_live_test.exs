defmodule LinkBuilderWeb.Admin.PlanLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest
  import LinkBuilder.BillingFixtures

  @create_attrs %{name: "some name", amount: 9900, currency: "usd"}
  @update_attrs %{name: "some updated name", amount: 8900, currency: "eur"}
  @invalid_attrs %{name: nil, amount: nil, currency: "usd"}

  defp create_plan(_) do
    plan = plan_fixture(%{stripe_id: unique_stripe_id()})
    %{plan: plan}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_plan]

    test "lists all plans", %{conn: conn, plan: plan} do
      {:ok, _index_live, html} = live(conn, Routes.admin_plan_index_path(conn, :index))

      assert html =~ "Listing Plans"
      assert html =~ plan.stripe_id
    end

    test "saves new plan", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_plan_index_path(conn, :index))

      assert index_live |> element("a[href=\"/admin/plans/new\"]") |> render_click() =~
               "New Plan"

      assert_patch(index_live, Routes.admin_plan_index_path(conn, :new))

      assert index_live
             |> form("#plan-form", plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#plan-form", plan: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_plan_index_path(conn, :index))

      assert html =~ "Plan created successfully"
      assert html =~ "some name"
    end

    test "updates plan in listing", %{conn: conn, plan: plan} do
      {:ok, index_live, _html} = live(conn, Routes.admin_plan_index_path(conn, :index))

      assert index_live |> element("#plan-#{plan.id} a", "Edit") |> render_click() =~
               "Edit Plan"

      assert_patch(index_live, Routes.admin_plan_index_path(conn, :edit, plan))

      assert index_live
             |> form("#plan-form", plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#plan-form", plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_plan_index_path(conn, :index))

      assert html =~ "Plan updated successfully"
      assert html =~ "some updated name"
    end

    test "archives plan in listing", %{conn: conn, plan: plan} do
      {:ok, index_live, _html} = live(conn, Routes.admin_plan_index_path(conn, :index))

      html = index_live |> element("#plan-#{plan.id} a", "Archive") |> render_click()

      assert html =~ "Activate"
      assert html =~ "Archived"
    end
  end

  describe "Show" do
    setup [:create_plan]

    test "displays plan", %{conn: conn, plan: plan} do
      {:ok, _show_live, html} = live(conn, Routes.admin_plan_show_path(conn, :show, plan))

      assert html =~ "Show Plan"
      assert html =~ plan.stripe_id
    end

    test "updates plan within modal", %{conn: conn, plan: plan} do
      {:ok, show_live, _html} = live(conn, Routes.admin_plan_show_path(conn, :show, plan))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Plan"

      assert_patch(show_live, Routes.admin_plan_show_path(conn, :edit, plan))

      assert show_live
             |> form("#plan-form", plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#plan-form", plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_plan_show_path(conn, :show, plan))

      assert html =~ "Plan updated successfully"
      assert html =~ "some updated name"
    end
  end
end
