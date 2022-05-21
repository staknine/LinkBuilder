defmodule LinkBuilderWeb.Views.DateHelpers do
  @moduledoc """
  Convenience functions for displaying dates.
  """

  def human_date(%NaiveDateTime{year: year} = date) do
    formatter = if year == DateTime.utc_now.year, do: "%d %b", else: "%d %b - %Y"

    date
    |> NaiveDateTime.to_date
    |> Timex.format!(formatter, :strftime)
  end

  def human_date(_), do: nil
end
