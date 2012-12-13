require "mongo_mapper"
require "frisky"
require "bundler"

Bundler.require(:test, :default)

Frisky.config_file "#{File.dirname(__FILE__)}/../frisky.yml"
Frisky.log.level = Logger::FATAL

EphemeralResponse.activate

def reset_databases
  MongoMapper.connection.drop_database MongoMapper.database.name
  redis = Redis.new
  redis.flushdb
end
