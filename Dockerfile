FROM rails:latest

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

EXPOSE 3000
CMD bundle exec rails server -b 0.0.0.0 -p 3000
