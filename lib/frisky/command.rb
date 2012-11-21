module Frisky
  # This class provides the foundations for a standalone command
  class Command
    extend ActiveSupport::Concern

    attr_reader :options

    def initialize(options)
      @options = options

      Frisky.config_file @options[:config] if @options[:config]

      Frisky.log.level = case
        when @options[:debug]; ::Logger::DEBUG
        when @options[:verbose]; ::Logger::INFO
        else; ::Logger::WARN
        end

      # Require the debugger if its going to be used
      if options[:debug]
        Bundler.require(:development)
      else
        def debugger; end
      end
    end

    # Override this method with the custom run method
    def run
      Frisky.log.warn "noop"
    end

    def self.run(name, options={})
      options[:config] ||= "#{ENV['PWD']}/frisky.yml"

      OptionParser.new do |opts|
        opts.banner = "Usage: #{name} [OPTIONS]"

        opts.on('-v', '--verbose', 'Run verbosely') {|v| options[:verbose] = v }
        opts.on('-d', '--debug', 'Run with debugging messages') {|v| options[:debug] = v }
        opts.on('-c', '--config CONFIG', "Configuration file (default: #{options[:config]})") { |v| options[:config] = v}

        yield opts if block_given?
      end.parse!

      new(options).run
    end
  end
end