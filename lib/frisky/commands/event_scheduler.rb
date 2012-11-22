require 'frisky/helpers/github'
require 'frisky/command'
require 'frisky'

module Frisky
  module Commands
    # The EventScheduler pulls events from github's API and schedules
    # push events to be PushProcessor queue for processing.
    class EventScheduler < Frisky::Command
      def perform
        pushed_events = 0

        10.times do |page_number|
          Frisky::Helpers::GitHub.fetch_url(@options[:url], per_page: 30, page: page_number+1).each do |event|
            next if Frisky::Model::Event.exists?(event)
            e = Frisky::Model::Event.create(event)

            # Schedule the processing of push events
            if e.push?
              pushed_events += 1

              Frisky.redis.publish('events', {id: e.id, type: e.type}.as_json)
            end
          end
        end

        Frisky.log.info "Created #{pushed_events} push jobs"
      end

      def run
        loop do
          perform

          break unless options[:loop]
          sleep @options[:loop].to_i
        end
      end
    end
  end
end