FROM hub.services.bigcommerceapp.com/bigcommerce/ruby:2.1.5

ENV USE_ENV true
ENV WORKDIR /opt/services/pact_broker
ENV BUNDLE_PATH /var/bundle
ENV GEM_HOME $BUNDLE_PATH
ENV CUSTOM_RUBY_VERSION 2.1.5
ENV HOME $WORKDIR
ENV BUNDLE_APP_CONFIG $GEM_HOME

RUN groupadd app &&\
    useradd -g app -d $WORKDIR -s /sbin/nologin -c 'Docker image use for the app' app &&\
    mkdir -p $WORKDIR $BUNDLE_PATH

WORKDIR /opt/services/pact_broker

COPY pact_broker/Gemfile* $WORKDIR/
RUN apt-get update && apt-get install -y -q \
    mysql-client \
    mysql-common \
    libmysqlclient-dev \
    sqlite3 \
    libsqlite3-dev &&\
    bundle install --system --without='development test' &&\
    rm -rf /var/lib/apt/lists/*

RUN chown -R app:app $WORKDIR $GEM_HOME

COPY pact_broker/ $WORKDIR/

EXPOSE 9292
CMD ["sh",  "-c", "bundle exec rackup -o 0.0.0.0"]
