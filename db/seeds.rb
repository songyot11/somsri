# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Employee.delete_all
Payroll.delete_all

school = School.create({ name: "โรงเรียนแห่งหนึ่ง" })

user = User.new
user.email = 'test@test.com'
user.encrypted_password = '$2a$11$PA6IWsalB0R4rDa1yHYBcuaKFyz2MgR8.d1G2TQk0qIm0QINhpjSa'
user.password = 'valid_password'
user.password_confirmation = 'valid_password'
user.school_id = school.id
user.save

em1 = Employee.create({
  school_id: school.id,
  first_name: "Somsri",
  last_name: "Penchueapp",
  first_name_thai: "สมศรี",
  last_name_thai: "เป็นชื่อแอพ",
  prefix: "Mrs",
  prefix_thai: "นาง",
  sex: 1,
  position: "ครูน้อย",
  personal_id: "1409733340586",
  passport_number: "EVE639280394SE",
  race: "ไทย",
  nationality: "ไทย",
  bank_name: "กสิกรไทย",
  bank_branch: "ใจกลางเมืองเชียงใหม่",
  account_number: "5-234-34532-2342",
  salary: 50000,
  img_url: "http://pm1.narvii.com/5817/029f4148b86a82717ff26e7b8bf2340457f32ae8_hq.jpg"
})

em2 = Employee.create({
  school_id: school.id,
  first_name: "Somsak",
  last_name: "Penkai",
  first_name_thai: "สมศักดิ์",
  last_name_thai: "เป็นใคร",
  prefix: "Mr",
  prefix_thai: "นาย",
  sex: 0,
  position: "ภารโรง",
  personal_id: "1409709840586",
  passport_number: "EVA111111394SE",
  race: "ไทย",
  nationality: "อเมริกา",
  bank_name: "ธนาคารม่วง",
  bank_branch: "ใกล้บ้านท่าน่",
  account_number: "5-234-11111-2342",
  salary: 250000
})

em3 = Employee.create({
  school_id: school.id,
  first_name: "Eve",
  last_name: "Akiyama",
  middle_name: "Britannia",
  prefix: "Her Majesty Queen",
  sex: 1,
  position: "ครูใหม่",
  personal_id: "1409709840000",
  passport_number: "E000000000000E",
  race: "",
  nationality: "britannia",
  bank_name: "ธนาคารเหลือง",
  bank_branch: "หลัก",
  account_number: "5-124-11111-2342",
  salary: 25_000
})

em4 = Employee.create({
  school_id: school.id,
  first_name: "King",
  last_name: "Akiyama",
  middle_name: "Britannia",
  prefix: "Mr.",
  sex: 0,
  position: "NPC",
  personal_id: "140345560000",
  passport_number: "E001000000000E",
  race: "",
  nationality: "britannia",
  bank_name: "ขุดหลุมฝัง",
  bank_branch: "ข้างๆต้นไม้หน้าถ้ำ",
  account_number: "5-124-222222-2342",
  salary: 25_000,
  img_url: "http://static.zerochan.net/Takimoto.Hifumi.full.2031929.jpg"
})

pr1_1 = Payroll.create({
  employee_id: em1.id,
  salary:25_000,
  tax: 100,
  created_at: Date.new(2016, 1, 16)
})

pr1_2 = Payroll.create({
  employee_id: em1.id,
  salary: 25_000,
  allowance: 2_500,
  tax: 968,
  social_insurance: 750,
  late: 500,
  created_at: Date.new(2016, 2, 16)
})

pr2 = Payroll.create({
  employee_id: em2.id,
  salary: 250000,
  tax: 500000,
  social_insurance: 750,
  created_at: Date.new(2016, 1, 16)
})

pr2_2 = Payroll.create({
  employee_id: em2.id,
  salary: 250000,
  tax: 500000,
  created_at: Date.new(2016, 2, 16)
})

pr3 = Payroll.create({
  employee_id: em3.id,
  salary: 25_000,
  tax: 1,
  allowance: 1000000,
  ot: 200,
  created_at: Date.new(2016, 1, 16)
})

pr3_2 = Payroll.create({
  employee_id: em3.id,
  salary: 25_000,
  tax: 750,
  allowance: 1000000,
  ot: 200,
  created_at: Date.new(2016, 2, 16)
})

pr4 = Payroll.create({
  employee_id: em4.id,
  salary: 25_000,
  tax: 750,
  fee_etc: 1000000,
  created_at: Date.new(2016, 1, 1)
})

pr4_2 = Payroll.create({
  employee_id: em4.id,
  salary: 25_000,
  tax: 750,
  fee_etc: 1000000,
  created_at: Date.new(2016, 2, 1)
})
