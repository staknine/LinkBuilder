defmodule LinkBuilderWeb.AppChannelTest do
  use LinkBuilderWeb.ChannelCase

  import LinkBuilder.AccountsFixtures

  setup do
    user = user_fixture()

    {:ok, _, socket} =
      LinkBuilderWeb.UserSocket
      |> socket("user_id", %{user_id: user.id})
      |> subscribe_and_join(LinkBuilderWeb.AppChannel, "app:lobby")

    %{socket: socket, app_channel: "app:lobby"}
  end

  test "flash message notifies subscribers and replies with status ok", %{socket: socket, app_channel: app_channel} do
    Phoenix.PubSub.subscribe(LinkBuilder.PubSub, app_channel)

    ref = push socket, "flash", %{"body" => "Hi there"}
    assert_reply ref, :ok, %{"body" => "Hi there"}
    assert_receive {:notify, %{"body" => "Hi there"}}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
