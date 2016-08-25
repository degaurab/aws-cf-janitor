$LOAD_PATH << File.expand_path('./lib', File.dirname(__FILE__))
require 'cf_janitor/app'

STDOUT.sync = true

run CfJanitor::App
