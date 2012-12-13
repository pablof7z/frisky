require 'frisky/command'
require 'frisky/classifier'
require 'frisky'
require 'socket'

THREAD_LIMIT = 1000

module Frisky
  module Commands
    # This command listens to events that are queued by the event-scheduler command.
    # The classifiers command will load the classifiers it knows about,
    # and will maintain them online so that their requested events are served to them.
    class Classifiers < Frisky::Command
      attr_reader :options, :classifiers

      def initialize(*args)
        @processes   = {}
        @classifiers = {}
        super(*args)

        # Load classifiers
        (options[:load_classifiers]||Dir.glob("classifiers/*.rb")).each do |file|
          begin
            load_classifier(file)
          rescue StandardError => e
            Frisky.log.fatal e.message
            exit(1)
          end
        end

        Frisky.log.info "Loaded #{@classifiers.count} classifiers: #{@classifiers.keys.join(', ')}"
      end

      # Attempts to load a classifier from a file.
      # It validates that a valid classifier is loaded and adds it to the list
      # of classifiers
      def load_classifier(file)
        load file

        # Validate that the expected class was loaded
        class_name = File.basename(file, '.*').camelize
        klass = Kernel.const_get(class_name.to_sym)

        # Load it
        self.classifiers[klass.name] = klass
      rescue NameError
        raise Frisky::InvalidClassName, "Expected #{file} to define #{class_name}"
      end

      # Relay a signal to all the forked processes
      # When the signal is `SIGINT`, `waitpid(2)` on the process and exit. Signaling SIGINT twice within 5 seconds
      # sends a `SIGKILL` to the processes and aborts immediately.
      def relay_signal(signal)
        Frisky.log.debug "Sending SIG#{signal} to #{@processes.count} processes"

        if @previous_sigint.to_i > (Time.now.to_i - 5)
          signal = 'KILL'
        else
          Frisky.log.warn "Ctrl-C again to stop immediately"
          @previous_sigint = Time.now
        end if signal == 'INT'

        # Send signals
        @processes.each {|name, pid| Process.kill signal, pid }

        # Special signal handling
        case signal
        when 'INT'
          @processes.each do |name, pid|
            Frisky.log.info name
            Process.waitpid pid
          end
          exit(1)
        end
      end

      def run
        # Run each classifier on its own process
        @classifiers.each do |name, klass|
          next if klass.events.empty?

          if @processes[name] = Kernel.fork
            Frisky.log.debug "Forked #{name} -- #{@processes[name]}"
          else
            Resque::Worker.new(name).work(1)
            exit!(0)
          end
        end

        # Relay signals to subprocesses
        %w(USR1 USR2 TERM INT).each {|signal| trap(signal) { relay_signal(signal) } }

        # Run announcements on the main process
        loop { announce_classifiers; sleep 60 }
      end

      # Stores the loaded classifiers into a zset along with the current timestamp (so it can be expired)
      #
      # See Frisky::Commands::EventScheduler.fetch_loaded_classifiers for a description of how
      # classifiers are stored.
      def announce_classifiers
        announced = 0

        @classifiers.each { |name, klass| announced += 1 if klass.announce }

        Frisky.log.debug "Announced #{announced} classifiers from #{$$}"
      end
    end
  end
end
