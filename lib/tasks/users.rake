desc "Create user"
namespace :user do
  task :create,  [:email, :password] => :environment do |t, args|
    school = School.last
    if school
      if User.create(
          school_id: school.id,
          email: args.email,
          password: args.password
        )
        puts 'user has been created'
      else
        puts 'cannot create user'
      end
    else
      puts 'please create a new school'
    end
  end
end
