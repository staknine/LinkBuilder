defmodule LinkBuilder.Mailer do
  use Swoosh.Mailer, otp_app: :link_builder

  def deliver_later(email) do
    deliver(email)
  end
end
