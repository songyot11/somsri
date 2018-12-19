FROM rails:latest

ENV RAILS_ENV production

ENV APP_HOME /app/somsri/payroll
RUN mkdir $APP_HOME -p
WORKDIR $APP_HOME

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get update \
  && apt-get install -y nodejs

RUN npm install -g bower

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME/

RUN cp config/application_sample.yml config/application.yml
RUN cp config/database_sample.yml config/database.yml

#RUN RAILS_GROUPS=assets bundle exec rake assets:precompile

CMD puma -C config/puma.rb
