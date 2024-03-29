FROM node:12.14.1 AS nodejs
FROM ruby:3.1.3
WORKDIR /usr/src/app
ENV RAILS_ENV=production
ENV KUBY_ENV=production
ARG RAILS_MASTER_KEY
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends apt-transport-https && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends apt-utils && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends \
  ca-certificates
COPY --from=nodejs /usr/local/bin/node /usr/local/bin/node
RUN wget https://github.com/yarnpkg/yarn/releases/download/v1.21.1/yarn-v1.21.1.tar.gz && \
  yarnv=$(basename $(ls yarn-*.tar.gz | cut -d'-' -f 2) .tar.gz) && \
  tar zxvf yarn-$yarnv.tar.gz -C /opt && \
  mv /opt/yarn-$yarnv /opt/yarn && \
  apt-get install -qq -y --no-install-recommends gnupg && \
  wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --import && \
  wget https://github.com/yarnpkg/yarn/releases/download/$yarnv/yarn-$yarnv.tar.gz.asc && \
  gpg --verify yarn-$yarnv.tar.gz.asc
ENV PATH=$PATH:/opt/yarn/bin
RUN gem install bundler -v 2.4.7
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
