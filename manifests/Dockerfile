FROM ruby:3.0.3
WORKDIR /usr/src/app
ENV RAILS_ENV=production
ENV KUBY_ENV=production
ARG RAILS_MASTER_KEY
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends apt-transport-https && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends apt-utils && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends \
  ca-certificates
RUN gem install bundler -v 2.3.4
COPY Gemfile .
COPY Gemfile.lock .
ENV BUNDLE_WITHOUT='development test deploy'
ARG MINIO_ACCESS_KEY=required
ARG MINIO_SECRET_KEY=required
ENV MINIO_ACCESS_KEY ${MINIO_ACCESS_KEY}
ENV MINIO_SECRET_KEY ${MINIO_SECRET_KEY}
RUN gem install specific_install
RUN gem specific_install https://github.com/kingdonb/prebundler
COPY .prebundle_config .
RUN prebundle install
ENV PATH=./bin:$PATH
COPY ./ .
RUN bundle exec rake assets:precompile
CMD puma --workers 4 --bind tcp://0.0.0.0 --port 8080 --pidfile ./server.pid ./config.ru
EXPOSE 8080
