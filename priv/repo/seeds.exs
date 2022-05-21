# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LinkBuilder.Repo.insert!(%LinkBuilder.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import LinkBuilder.AccountsFixtures
import LinkBuilder.BillingFixtures

alias LinkBuilder.InAppNotifications

Enum.each(1..Faker.Util.pick(10..20), fn _ ->

  account = account_fixture(%{name: Faker.Company.name()})
  billing_customer = customer_fixture(account, %{stripe_id: unique_stripe_id()})

  Enum.each(1..Faker.Util.pick(2..20), fn _ ->
    user = user_fixture(account)

    Enum.each(1..Faker.Util.pick(2..10), fn _ ->
      InAppNotifications.create_notification(user, %{
        type: Faker.Util.pick(~w(flash email in_app)),
        title: Faker.Company.catch_phrase(),
        body: Faker.Company.catch_phrase()
      })
    end)
  end)
end)
