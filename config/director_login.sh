#!/bin/env bash

BUNDLE_GEMFILE=/home/tempest-web/tempest/web/vendor/bosh/Gemfile bundle exec bosh login >/dev/null <<-END
$1
$2
END
