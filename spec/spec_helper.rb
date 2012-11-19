require "frisky"
require "bundler"

Bundler.require(:test, :default)

MONGO_URI = 'mongodb://localhost/frisky-test'
REDIS_HOSTNAME = '127.0.0.1'
