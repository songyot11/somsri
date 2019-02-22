FROM ruby:2.3.1-alpine

RUN apk --update add nodejs netcat-openbsd postgresql-dev linux-headers openssl imagemagick imagemagick-dev tzdata git
RUN apk --update add --virtual build-dependencies make g++
RUN apk update \
    && apk add sqlite \
    && apk add socat \
    && apk add sqlite-dev

#ENV RAILS_ENV production

ENV APP_HOME /app/somsri/payroll
RUN mkdir $APP_HOME -p
WORKDIR $APP_HOME

RUN npm install -g bower

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME/

RUN cp config/application_sample.yml config/application.yml
RUN cp config/database_sample.yml config/database.yml

COPY package.json bower.json $APP_HOME/
RUN npm install --only=prod && \
    npm cache clean && \
    bower install --allow-root
    
RUN RAILS_GROUPS=assets bundle exec rake assets:precompile

CMD puma -C config/puma.rb
