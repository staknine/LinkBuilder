defmodule LinkBuilderWeb.Schema.GetUsersTest do
  use LinkBuilderWeb.ConnCase, async: true
  import LinkBuilder.GraphqlTestHelpers

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    query {
      users {
        id
      }
    }
  """

  defp get_post_args do
    %{
      query: @query
    }
  end

  describe "when not logged in" do
    setup [:user_with_invalid_jwt]

    test "get users with invalid credentials", %{conn: conn} do
      args = get_post_args()

      response =
        conn
        |> get_response(args)

      assert %{
               "data" => %{"users" => nil},
               "errors" => [
                 %{
                   "locations" => [_],
                   "message" => "Not Authorized",
                   "path" => ["users"]
                 }
               ]
             } = json_response(response, 200)
    end
  end

  describe "when logged in" do
    setup [:user_with_valid_jwt]

    test "get users with valid credentials", %{conn: conn, jwt: jwt} do
      args = get_post_args()

      response =
        conn
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> get_response(args)

      assert %{
               "data" => %{
                 "users" => [%{"id" => _}]
               }
             } = json_response(response, 200)
    end
  end
end
