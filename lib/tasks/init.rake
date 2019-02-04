desc "To create all required data"
namespace "init" do
  task :school,  [:school_name] => :environment do |t, args|
    school = School.first
    if school
      school.update(name: args.school_name)
    else
      School.create(name: args.school_name)
    end
    puts "Created 'Somsri' school"

    # admin
    user = User.find_by_email("admin@bananacoding.com")
    user ||= User.create!(
      email: "admin@bananacoding.com",
      password: "password",
      password_confirmation: "password",
      reset_password_token: nil,
      reset_password_sent_at: nil,
      remember_created_at: nil,
      sign_in_count: 2,
      current_sign_in_at: "2016-12-26 07:33:11",
      last_sign_in_at: "2016-12-26 07:28:33",
      current_sign_in_ip: "180.183.204.78",
      last_sign_in_ip: "180.183.204.78",
      name: nil
    )

    unless user.has_role? :admin
      user.add_role :admin
    end
    puts "Created an admin('admin@bananacoding.com')"

    # taxrate
    if Taxrate.count == 0
      Taxrate.create!([
       {order_id: "1", income: "5000000", tax: "0.35"},
       {order_id: "2", income: "2000000", tax: "0.30"},
       {order_id: "3", income: "1000000", tax: "0.25"},
       {order_id: "4", income: "750000", tax: "0.20"},
       {order_id: "5", income: "500000", tax: "0.15"},
       {order_id: "6", income: "300000", tax: "0.10"},
       {order_id: "7", income: "150000", tax: "0.05"}
      ])
    end

    # invoice
    AccountType.create([{ name: 'Income' }, { name: 'Expenses' }]) if AccountType.count == 0
    Gender.create([{ name: 'Male'},{ name: 'Female'}]) if Gender.count == 0
    Grade.create([{ name: 'Preschool' },{ name: 'Kindergarten 1' },{ name: 'Kindergarten 2' },{ name: 'Kindergarten 3' }]) if Grade.count == 0
    Relationship.create([{ name: 'Father' }, { name: 'Mother' }, { name: 'Grandfather' }, { name: 'Grandmother' }, { name: 'Uncle' }, { name: 'Aunt' }, { name: 'Cousin' }]) if Relationship.count == 0
    InvoiceStatus.create([{ name: 'Active' }, { name: 'Canceled' }]) if InvoiceStatus.count == 0

    puts "Prepared config data"

    # CMS
    puts "Create Default CMS Site"
    if Comfy::Cms::Site.count == 0
      Comfy::Cms::Site.create!({label: 'Somsri School', identifier: 'default', hostname: 'localhost', locale: 'en', is_mirrored: 'f'})
    end
    puts "Finished"
  end
end
