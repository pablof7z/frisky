# This file keeps logic to load configurations of the entire library

module Frisky
  @@mongo          = nil
  @@mongo_database = nil
  @@redis          = nil
  @@config         = nil
  @@log            = nil

  class << self
    def config=(config)
      @@config = config

      @@mongo = Mongo::Connection.from_uri(config['mongo']) if config['mongo']
      @@redis = Redis.new(host: config['redis']) if config['redis']

      if @@mongo
        uri                    = URI.parse(config['mongo'])
        @@mongo_database        = uri.path.gsub(/^\//, '')
        MongoMapper.connection = @@mongo
        MongoMapper.database   = @@mongo_database
      end

      # Github
      if config['github'] and config['github']['keys']
        client_id, client_secret              = config['github']['keys'].sample.split(/:/)
        Frisky::Helpers::GitHub.client_id     = client_id
        Frisky::Helpers::GitHub.client_secret = client_secret
      end
    end

    def config_file(file)
      Frisky.config = YAML.load_file(file)
    end

    def config; @@config; end
    def mongo; @@mongo; end
    def redis; @@redis; end
    def valid?; (@@mongo != nil and @@redis != nil); end

    def log;
      if @@log == nil
        @@log                 = ::Logger.new(STDOUT)
        @@log.datetime_format = "%H:%M:%S"
        @@log.formatter = proc do |severity, datetime, progname, msg|
          "[#{severity}] #{datetime}: #{msg}\n"
        end
      end

      @@log
    end

    def reset!
      @@mongo = @@mongo_database = @@redis = @@config = nil
    end
  end
end