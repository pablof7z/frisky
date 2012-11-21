require 'frisky/command'
require 'frisky'
require 'socket'

THREAD_LIMIT = 1000

module Frisky
  module Commands
    class Classifiers < Frisky::Command
      attr_reader :options

      @id = "#{Socket.gethostname}-#{$$}"
      @@threads = []

      def handle_push(event)
        Frisky.classifiers.each do |name, classifier|
          next unless Frisky::Lock.lock? "#{event.id}:#{name}"

          @@threads << Thread.new do
            begin
              Frisky.log.info "Processing push event on #{event.id} #{name}"

              # Walk each commit in the push event
              event.commits.each do |commit|
                classifier.hooks[:commit].each do |commit_hook_data|
                  commit_hook, hook_params = commit_hook_data
                  classifier.send commit_hook, commit
                end
              end

            rescue StandardError => e
            ensure
              Frisky::Lock.unlock "#{event.id}:#{name}"
            end
          end

          # When we go over threshold with threads, remove dead threads
          while @@threads.count > THREAD_LIMIT
            @@threads.delete_if do |thread|
              t.alive? ? false : t.join
            end
          end
        end
      end

      def handle_event(event)
        case
        when event.push?; handle_push(event)
        end
      end

      def run
        # Load classifiers
        Dir.glob("classifiers/*.rb") do |file|
          load file
        end

        Frisky.log.info "Loaded #{Frisky.classifiers.count} classifiers: #{Frisky.classifiers.keys.join(', ')}"

        # Redis connections can be simultaneously used for other non pubsub operations
        # while subscribed.
        # Duplicate redis connection for pubsub use.
        subscribe_redis_connection = Redis.new host: Frisky.redis.client.host

        subscribe_redis_connection.subscribe('events') do |on|
          on.message do |channel, msg|
            begin
              data = JSON.parse(msg)

              Frisky.log.info "Message on channel #{channel}: #{msg}"

              case channel
              when 'events'
                event = Frisky::Model::Event.find!(data['id'])
                handle_event(event)
              end

            rescue StandardError => e
              Frisky.log.warn "Error: #{e.message}"
            end
          end
        end
      end
    end
  end
end
