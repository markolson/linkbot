FROM ruby:2.7

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /opt/bot

COPY Gemfile Gemfile.lock ./
# install matching version of bundler
RUN gem install bundler -v "$(grep -A1 'BUNDLED WITH' Gemfile.lock | tail -n1)" --no-document
RUN bundle install

COPY . .

CMD ["./linkbot", "--config", "/opt/bot/config.json", "--database", "/opt/bot/data.sqlite3"]
