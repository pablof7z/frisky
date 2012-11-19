module Frisky
  module Config
    @@mongo    = nil
    @@redis    = nil
    @@config   = nil

    class << self
      def config=(config)
        @@config = config

        @@mongo = Mongo::Connection.from_uri(config[:mongo]) if config[:mongo]
        @@redis = Redis.new(host: config[:redis]) if config[:redis]
      end

      def config
        @@config
      end

      def valid?
        @@mongo and @@redis
      end
    end
  end
end