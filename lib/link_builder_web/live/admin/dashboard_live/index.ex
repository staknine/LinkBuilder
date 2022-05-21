defmodule LinkBuilderWeb.Admin.DashboardLive.Index do
  use LinkBuilderWeb, :live_view_admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  alias Contex.{Dataset, Plot, LinePlot}

  defp pie_chart do
    height = 400
    width = 600
    label = ""
    data = [
      ["Cat", 10.0],
      ["Dog", 20.0],
      ["Hamster", 5.0]
    ]

    opts = [
      mapping: %{category_col: "Pet", value_col: "Preference"},
      legend_setting: :legend_right,
      data_labels: true,
      title: label
    ]

    chart =
      data
      |> Dataset.new(["Pet", "Preference"])
      |> Contex.Plot.new(Contex.PieChart, width, height, opts)
      |> Plot.to_svg()

    chart
  end

  defp bar_chart do
    data = [
      ["Apples", 10],
      ["Bananas", 12],
      ["Pears", 2]
    ]

    data
    |> Contex.Dataset.new()
    |> Contex.Plot.new(Contex.BarChart, 600, 400)
    |> Contex.Plot.to_svg()
  end

  defp line_chart do
    data = [
      [1, 4],
      [2, 12],
      [3, 10],
      [4, 12],
      [5, 15],
      [6, 17],
      [7, 18],
      [8, 16],
      [9, 13],
      [10, 10],
      [11, 27],
      [12, 32],
      [13, 10],
      [14, 12],
      [15, 15],
      [16, 17],
      [17, 18],
      [18, 16],
      [19, 13],
    ]

    plot =
      Dataset.new(data, ["x-axis", "y-axis"])
      |> LinePlot.new(mapping: %{x_col: "x-axis", y_cols: ["y-axis"]})

    Plot.new(300, 200, plot)
    |> Plot.to_svg()
  end
end
