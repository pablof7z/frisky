require 'frisky/command'
require 'frisky'

module Frisky
  module Commands
    # The EventScheduler pulls events from github's API and schedules
    # push events to be PushProcessor queue for processing.
    class EventScheduler < Frisky::Command
      attr_reader :classifiers

      def initialize(*args)
        super(*args)

        @classifiers = {}
      end

      def perform(pages_to_fetch=1)
        pushed_jobs = 0

        # Get 10 pages of of events
        pages_to_fetch.times do |page_number|
          Octokit.get(@options[:url], per_page: 30, page: page_number+1).each do |event_raw|
            event_type = event_raw.type

            @classifiers.each do |name, event_types|
              begin
                # Does this classifier support this event?
                next unless event_types.include? event_type

                Resque.push(name, 'class' => name, args: event_raw.to_json)
                pushed_jobs += 1
              rescue StandardError => e
                Frisky.log.warn "[#{e.class}] #{e.message}"
                e.backtrace[0..9].each {|a| Frisky.log.info a}
              end
            end
          end
        end

        Frisky.log.info "Created #{pushed_jobs} jobs"
      end

      # Removes expired keys and catches the remaining keys
      # TODO -- Check for backed up queues and skip them so huge backlogs are avoided.
      #
      # Classifiers exist on a sorted set in redis, using the time of last ping
      # as the score, and the name of the classifier as the key.
      #
      # This method is called periodically to prune the list of classifiers and cache
      # the available classifiers so each event is pushed to each classifier.
      #
      # Classifiers also push a filter to a set, so they will only receive the type of events
      # they are interested in processing. The set is named classifier:#{name}:config:supported_events, and is also cached
      def fetch_loaded_classifiers
        # find expired classifiers
        time = Time.now.utc.to_i
        expired = Frisky.redis.zrangebyscore("classifiers", "-inf", "(#{time-90}")

        if expired.any?                                                            # Delete expired classifiers
          Frisky.log.warn "Dropping expired classifiers: #{expired.join(', ')}"    # that are not longer running
          Frisky.redis.zrem("classifiers", expired)
        end

        # Get classifiers that match now+-90 to now in order to skip classifiers created too far in the future
        new_classifiers = {}
        Frisky.redis.zrangebyscore("classifiers", "#{time-90}", "#{time+90}").each do |classifier_name|
          new_classifiers[classifier_name] = Frisky.redis.smembers("classifier:#{classifier_name}:config:events")
        end
        Frisky.log.info "Loaded new classifiers: #{(new_classifiers.keys - @classifiers.keys).join(', ')}" if (new_classifiers.keys - @classifiers.keys).any?
        @classifiers.clear
        @classifiers.merge!(new_classifiers)
      end

      def run
        loop do
          fetch_loaded_classifiers

          # Don't perform if we have no classifiers loaded that will do something with the data
          if @classifiers.any?
            perform
          else
            Frisky.log.info "Waiting for classifiers to connect"
          end

          break unless options[:loop]
          sleep @options[:loop].to_i
        end
      end
    end
  end
end