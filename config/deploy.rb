# config valid only for current version of Capistrano
lock '3.4.1'

set :application, 'somsri-payroll'
set :repo_url, 'git@github.com:BananaCoding/somsri.git'

set :default_stage, "production"

set :user, "deploy"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :branch, ENV['BRANCH'] || 'develop'

# Default deploy_to directory is /var/www/my_app_name
 set :deploy_to, '/srv/www/apps/somsri-payroll'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
 set :linked_files, fetch(:linked_files, []).push('config/unicorn.rb','config/database.yml', 'config/application.yml', 'config/paperclip.yml', 'config/aws.yml')

# Default value for linked_dirs is []
 set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :rvm_type, :system              # Defaults to: :auto
set :rvm_ruby_version, '2.3.3'      # Defaults to: 'default'

set :rails_env, 'production'

set :unicorn_bundle, nil
set :unicorn_pid, -> { "#{shared_path}/tmp/pids/unicorn.pid" }
set :unicorn_config_path, "config/unicorn.rb"
set :unicorn_rack_env, 'production' # "development", "deployment", or "none"

namespace :deploy do

 desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:restart'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
