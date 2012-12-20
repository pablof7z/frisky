# This file keeps logic to load configurations of the entire library

module Frisky
  @@redis          = nil
  @@config         = nil
  @@log            = nil

  class << self
    def config=(config)
      @@config = config

      @@redis = Redis.new(host: config['redis']) if config['redis']

      # Github
      if config['github'] and config['github']['keys']
        client_id, client_secret = config['github']['keys'].sample.split(/:/)
        Octokit.client_id        = client_id
        Octokit.client_secret    = client_secret
      end

      if defined? CONFIG_EXTENSIONS
        CONFIG_EXTENSIONS.each do |method|
          self.send(method, config)
        end
      end
    end

    def config_file(file)
      Frisky.config = YAML.load_file(file)
    end

    def config; @@config; end
    def redis; @@redis; end

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
  end
end