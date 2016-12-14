require 'machinist/active_record'

User.blueprint do
  provider { 'github' }
  uid      { "1234#{sn}" }
  email    { Faker::Internet.email }
  password { 'password' }
end

Project.blueprint do
  name { Faker::Commerce.product_name }
end

TestCase.blueprint do
  title { Faker::Lorem.word }
  description { Faker::Lorem.sentence }
  step { Faker::Lorem.paragraph }
end

TestRound.blueprint do
  name { Faker::Commerce.product_name }
end

TestResult.blueprint do
  title { Faker::Lorem.word }
  description { Faker::Lorem.sentence }
  step { Faker::Lorem.paragraph }
end
