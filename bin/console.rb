require 'bundler'

Bundler.require(:default, :development)

require 'mongo_mapper'
require 'frisky'

Frisky::Config.config_file "frisky.yml"