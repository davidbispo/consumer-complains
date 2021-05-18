FROM ruby:3.0.1

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install
COPY . .