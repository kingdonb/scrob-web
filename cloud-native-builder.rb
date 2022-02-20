#!/usr/bin/env bash

APP_ENV=development
APP_NAME=scrob-web
APP_PORT=9292
APP_PACKER=pack
BUILDPACK=https://cnb-shim.herokuapp.com/v1/yebyen/og-pack-multi
BUILDER=heroku/buildpacks:20

echo "To build the app:"
echo "$APP_PACKER build $APP_NAME --buildpack $BUILDPACK \\
  --builder $BUILDER"
echo
echo "To start the app in dev mode:"
echo "docker run -e DATABASE_URL='nulldb://nohost' -e RAILS_ENV=$APP_ENV -e RAILS_LOG_TO_STDOUT=true -p $APP_PORT:$APP_PORT -it $APP_NAME"
