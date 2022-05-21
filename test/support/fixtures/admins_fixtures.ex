defmodule LinkBuilder.AdminsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LinkBuilder.Admins` context.
  """

  def unique_admin_email, do: "admin#{System.unique_integer()}@example.com"
  def valid_admin_password, do: "hello world!"

  def admin_fixture(attrs \\ %{}) do
    {:ok, admin} =
      attrs
      |> Enum.into(%{
        email: unique_admin_email(),
        password: valid_admin_password(),
        password_confirmation: valid_admin_password()
      })
      |> LinkBuilder.Admins.create_admin()

    admin
  end
end
