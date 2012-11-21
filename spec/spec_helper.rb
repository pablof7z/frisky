require "mongo_mapper"
require "frisky"
require "bundler"

Bundler.require(:test, :default)

Frisky.config_file "#{File.dirname(__FILE__)}/../frisky.yml"

MongoMapper.connection.drop_database MongoMapper.database.name

EphemeralResponse.activate
