#!/bin/sh

bundle exec kuby -e development dockerfiles --only app > manifests/Dockerfile
bundle exec kuby -e development dockerfiles --only assets > manifests/Dockerfile.assets

# bundle exec kuby -e production resources | minus secrets
bundle exec ruby builder.rb # > outputs to - manifests/k8s.yml
