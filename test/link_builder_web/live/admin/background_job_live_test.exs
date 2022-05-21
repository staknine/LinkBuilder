defmodule LinkBuilderWeb.Admin.BackgroundJobLiveTest do
  use LinkBuilderWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_admin

  describe "Index" do
    test "lists all jobs", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.admin_background_job_index_path(conn, :index))

      assert html =~ "Listing Jobs"
    end
  end
end
