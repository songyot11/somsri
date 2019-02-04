namespace :employees do
  namespace :pin do
    desc "Generate pin for all employees"
    task :generate,  [] => :environment do |t, args|
      Employee.where(pin: nil).each do |e|
        e.save
        puts "#{e.first_name} #{e.last_name}: #{e.pin}" unless Rails.env.test?
      end
    end
  end
end
