module Frisky
  module Classifier
    module Queue
      extend ActiveSupport::Concern

      module ClassMethods
        # Announce the existence of this classifier and the events it supports
        # This method is to be used externally
        def announce
          return false if self.events.empty?

          Frisky.redis.zadd "classifiers", [Time.now.utc.to_i, self.name]
          Frisky.redis.sadd self.key(:events), self.events
          Frisky.redis.expire self.key(:events), 120

          return true
        end

        def perform(payload)
          # Load the payload into an event
          event = Frisky::Model::Event.load(JSON.parse(payload))

          # Attempt to multiplex this event
          method = "process_#{event.type.underscore}"
          raise NotImplemented, "Unsupported event #{event.type}" unless self.respond_to?(method)

          self.send(method, event)
        rescue JSON::ParserError => e
          Frisky.log.warn "Parser error in payload: #{e.message}"
        end

        def process_push_event(event)
          # Create a lazy loader for this push
          # push = Frisky::Model::Push.new_from_event(event)

          self.hooks[:push].each do |args|
            method = args.shift

            Frisky.log.debug "Will call #{method} (#{self.name})"

            # self.send(method, repo, push)
          end
        end

        def process_follow_event(event)
          self.hooks[:follow].each do |args|
            method = args.shift

            Frisky.log.debug "Will call #{method} (#{self.name})"

            # self.send(method, repo, push)
          end
        end
      end
    end
  end
end