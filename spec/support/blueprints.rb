require 'machinist/active_record'

# User.blueprint do
#   provider { 'github' }
#   uid      { "1234#{sn}" }
#   email    { Faker::Internet.email }
#   password { 'password' }
# end

School.blueprint do
  name { Faker::Lorem.word }
end

Employee.blueprint do
  school_id { Faker::Number.positive }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  prefix { Faker::Name.title }
  sex { Faker::Number.positive }
  account_number { Faker::Lorem.word }
  salary { Faker::Number.positive }
end

Payroll.blueprint do
  employee_id { Faker::Number.positive }
  salary { Faker::Number.positive }
  tax { Faker::Number.positive }
  created_at { Faker::Date }
end
