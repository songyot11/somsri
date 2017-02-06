require 'machinist/active_record'

User.blueprint do
  name { Faker::Name.first_name }
  email { Faker::Internet.email }
  password { 'password' }
end

School.blueprint do
  name { Faker::Lorem.word }
end

Employee.blueprint do
  school_id  { object.school ? object.school.id : School.make!.id }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  prefix { Faker::Name.title }
  first_name_thai { Faker::Name.first_name }
  last_name_thai { Faker::Name.last_name }
  prefix_thai { Faker::Name.title }
  sex { Faker::Number.positive }
  account_number { Faker::Lorem.word }
  salary { Faker::Number.positive }
  address { "#{Faker::Address.street_address} #{Faker::Address.city}" }
  tel { Faker::PhoneNumber.cell_phone }
  birthdate { Faker::Date }
  status { 'โสด' }
  email { Faker::Internet.email }
  employee_type { 'ลูกจ้างประจำ' }
end

Payroll.blueprint do
  employee_id { Faker::Number.positive }
  salary { Faker::Number.positive }
  tax { Faker::Number.positive }
  created_at { Faker::Date }
end

Taxrate.blueprint do
end
TaxReduction.blueprint do
end
