defmodule LinkBuilderWeb.PageController do
  use LinkBuilderWeb, :controller

  @app_name Application.get_env(:link_builder, :app_name)
  @company_name Application.get_env(:link_builder, :company_name)

  def privacy(conn, _params) do
    render(conn, "privacy.html", app_name: @app_name, company_name: @company_name)
  end

  def terms(conn, _params) do
    render(conn, "terms.html", app_name: @app_name, company_name: @company_name)
  end
end
