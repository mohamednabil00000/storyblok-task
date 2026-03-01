FROM ruby:4.0.1

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev cron && \
    rm -rf /var/lib/apt/lists/*

#RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN bundle install

# Just for a better reading
COPY . /myapp

RUN mkdir -p /myapp/health_check_files/pids

COPY /docker/startup.sh /usr/bin/
RUN chmod +x /usr/bin/startup.sh

COPY /docker/prepare-db.sh /usr/bin/
RUN chmod +x /usr/bin/prepare-db.sh

ENTRYPOINT ["/usr/bin/startup.sh"]
EXPOSE 3001

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
