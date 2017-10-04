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
- [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) or [pdftk for OSX](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg) or [pdftk for CentOS 7](https://www.linuxglobal.com/pdftk-works-on-centos-7/)
- [imagemagick] `brew install imagemagick`

##### setup project
- go to root directory
- run `bower install`
- run `bundle install`
- create database.yml or make a copy by running command
`cp config/database_sample.yml config/database.yml`
- run `rake db:create` to create database
- run `rake db:migrate` to build the schema
- run `rake db:seed` to generate sample data

##### To run project with Docker go to the project's directory
```
docker-compose build
docker-compose run app rails db:create db:migrate db:seed
docker-compose run app bower --allow-root install
docker-compose up
```

##### heroku
  since we are using bower and rails, we have to setup Heroku multiple build packs by using this command
```
heroku buildpacks:set heroku/ruby
heroku buildpacks:add --index 1 heroku/nodejs
heroku buildpacks:add --index 1 https://github.com/heroku/heroku-buildpack-apt
```
  and another command for auto migrate
```
heroku config:set DEPLOY_TASKS='db:migrate'
```
  to adding new build pack we have to add library name to Aptfile

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

  user following command to create a new user
```
rake user:create[<email>,<password>]
```

### install wkhtmltopdf 
For rendering pdf file. We need to install wkhtmltopdf
```
yum install wkhtmltopdf
```
fix problem rendering thai font
```
wget ftp://linux.thai.net/pub/thailinux/software/fonts-tlwg/fonts-tlwg-0.6.1.tar.xz
tar -xf fonts-tlwg-0.6.1.tar.xz
cd fonts-tlwg-0.6.1
sudo yum install fontforge
./configure
make
make install
cd ..
mkdir thai
find . -name '*.ttf' | cpio -pdm ./thai
cd thai
sudo cp -R fonts-tlwg-0.6.1/ /usr/share/fonts/
fc-cache -frv /usr/share/fonts/
```
https://github.com/wkhtmltopdf/wkhtmltopdf/issues/2496

CMS
-------
```
rake db:cms:seeds # init cms data
rake comfortable_mexican_sofa:fixtures:import FROM=default TO=default # import cms template
```

### on z.com
PG is need to be
```
   gem install pg -v '0.19.0' -- --with-pg-config=/usr/pgsql-9.6/bin/pg_config
```
