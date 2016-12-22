# Somsri-Payroll

### technologies
- RoR
- Angular 1.5

### package managers
- ruby gem
- bundler gem, you can install by running `gem install bundler`
- bower

### directories
- angular code: app/assets/javascripts/angular
- bower library: vendor/assets/bower_components

### how to start?
##### prerequisite
- rbenv and ruby
- bower

##### setup project
- go to root directory
- run `bower install`
- run `bundle install`
- create database.yml or make a copy by running command
`cp config/database_sample.yml config/database.yml`
- run `rake db:create` to create database
- run `rake db:migrate` to build the schema
- run `rake db:seed` to generate sample data

##### heroku
  since we are using bower and rails, we have to setup Heroku multiple build packs by using this command
```
heroku config:add BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
```
  and another command for auto migrate
```
heroku config:set DEPLOY_TASKS='db:migrate'
```

##### environment variables (ENV)
  We're using Figaro, so please create your own 'config/application.yml' by running
```
bundle exec figaro install
```
  you can see the required ENV in 'config/initializer/figaro.rb'

  ps. please also check 'config/application_sample.yml'

### rake command
  We're creating employee's payroll by using this command for create date now
```
rake payroll:generate:now
```
  and another command for create by month and year
```
rake payroll:generate:on[<month>,<year>]
```
example: rake payroll:generate:on[1,2016]
