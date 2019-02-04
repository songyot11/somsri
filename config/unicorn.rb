# config/unicorn.rb

app_name = "somsri-payroll"

worker_processes 2
timeout 480
preload_app true
working_directory "/srv/www/apps/#{app_name}/current"
listen "/srv/www/apps/#{app_name}/shared/sockets/unicorn.sock", :backlog => 64
pid "/srv/www/apps/#{app_name}/shared/tmp/pids/unicorn.pid"
stderr_path "/srv/www/apps/#{app_name}/shared/log/unicorn.stderr.log"
stdout_path "/srv/www/apps/#{app_name}/shared/log/unicorn.stdout.log"

before_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end

  sleep 1
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis = ENV['REDIS_URI']
    Rails.logger.info('Connected to Redis')
  end
end
