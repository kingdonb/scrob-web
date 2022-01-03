#!/bin/bash

unset BUNDLE_WITHOUT
bundle config --delete without
bundle install
RAILS_ENV=development puma --workers 4 --bind tcp://0.0.0.0 \
	--port 8080 --pidfile ./server.pid ./config.ru
