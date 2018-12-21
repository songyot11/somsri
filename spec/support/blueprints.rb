require 'machinist/active_record'

User.blueprint do
  name { Faker::Name.first_name }
  email { Faker::Internet.email }
  password { 'password' }
end

School.blueprint do
  name { Faker::Lorem.word }
  address { Faker::Address.street_address }
  phone { Faker::PhoneNumber.cell_phone }
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
  password { 'password' }
end

Payroll.blueprint do
  employee_id { Faker::Number.positive }
  salary { Faker::Number.positive }
  created_at { Faker::Date }
  closed            { true }
end

Taxrate.blueprint do
end

TaxReduction.blueprint do
end

TeacherAttendanceList.blueprint do
end

Individual.blueprint do
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  prefix { Faker::Name.title }
  first_name_thai { Faker::Name.first_name }
  last_name_thai { Faker::Name.last_name }
  prefix_thai { Faker::Name.title }
  phone { Faker::PhoneNumber.cell_phone }
  birthdate { Faker::Date }
  email { Faker::Internet.email }
end

Student.blueprint do
  prefix { Faker::Name.prefix }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  student_number{ rand(100000)+1 }
end

List.blueprint do
  name { Faker::Name.name }
  category { "roll_call" }
end

Parent.blueprint do
  full_name { Faker::Name.name }
  mobile { Faker::PhoneNumber.cell_phone }
end

StudentList.blueprint do
end

RollCall.blueprint do
  status { "มา" }
  round { "morning" }
end

Invoice.blueprint do
  school_year       { Time.current.year + 543 }
  semester          { 1 }
  parent_id         { object.parent ? object.parent.id : Parent.make!.id }
  student_id        { object.student ? object.student.id : Student.make!.id }
  invoice_status_id { object.invoice_status ? object.invoice_status.id : InvoiceStatus.make!.id }
end

InvoiceStatus.blueprint do
  name { Faker::Lorem.word }
end

LineItem.blueprint do
  detail { Faker::Lorem.sentence }
  amount { rand(10) + 1 }
end

LineItem.blueprint(:tuition) do
  detail { "ค่าธรรมเนียมการศึกษา / Tuition Fee" }
  amount { 48000 }
end

Grade.blueprint do
  name { Faker::Lorem.word }
end

Classroom.blueprint do
  name { Faker::Lorem.word }
  grade_id { object.grade ? object.grade.id : Grade.make!.id }
end

Gender.blueprint do
  name { Faker::Lorem.word }
end

StudentsParent.blueprint do
end

SchoolSetting.blueprint do
  school_year {"2560"}
  semesters {"1,2,3"}
  current_semester {"1"}
end

GroupingReportOption.blueprint do
end

Relationship.blueprint do
end

PaymentMethod.blueprint do
end

SiteConfig.blueprint do
  enable_rollcall { false }
  default_cash_payment_method { false }
  default_credit_card_payment_method { false }
  default_cheque_payment_method { false }
  default_transfer_payment_method { false }
  display_username_password_on_login { false }
  display_schools_year_with_invoice_id { false }
  tax { true }
  outstanding_notification { false }
  slip_carbon { false }
  enable_expenses { false }
end

Alumni.blueprint do
end

Expense.blueprint do
end

ExpenseItem.blueprint do
end

ExpenseTag.blueprint do
end

ExpenseTagItem.blueprint do
end
