require 'json'

module Frisky
  module Model
    class Event
      attr_accessor :type, :public, :payload, :repository, :actor, :commits, :ref,
                    :head

      def self.load_from_hashie(hashie)
        event = Event.new
        %w(type public ref head).each do |key|
          event.send("#{key}=", hashie.send(key)) if hashie.keys.include? key
        end
        event.actor = Person.soft_fetch(hashie.actor)
        event.repository = Repository.soft_fetch(hashie.repository)

        event.commits = []
        if hashie.keys.include? "commits"
          hashie.commits.each do |commit|
            event.commits << Frisky::Model::Commit.soft_fetch(commit)
          end
        end

        event
      end

      def self.load_from_raw(raw)
        event            = Event.new
        event.type       = raw.type
        event.public     = raw.public
        event.actor      = Person.soft_fetch(raw.actor)
        event.repository = Repository.soft_fetch(raw.repo) if raw.repo and raw.repo.name

        # Load payload
        method = "process_#{raw.type.underscore}".to_sym
        if event.respond_to? method
          event.send(method, raw)
        else
          raise NotImplemented, "Event type #{raw.type} not supported"
        end

        event
      end

      def process_push_event(raw)
        self.commits = []
        raw.payload.commits.each do |commit|
          commit.repository = self.repository
          self.commits << Frisky::Model::Commit.soft_fetch(commit)
        end

        self.ref  = raw.payload.ref
        self.head = raw.payload.head
      end

      def process_create_event(raw); end
      def process_watch_event(raw); end
      def process_issues_event(raw); end
      def process_issue_comment_event(raw); end
      def process_pull_request_event(raw); end
      def process_gist_event(raw); end
      def process_gollum_event(raw); end
      def process_follow_event(raw); end
      def process_fork_event(raw); end
      def process_commit_comment_event(raw); end
      def process_delete_event(raw); end
      def process_member_event(raw); end
      def process_pull_request_review_comment_event(raw); end
      def process_download_event(raw); end
      def process_public_event(raw); end

      # Check whether an event has been stored
      # Frisky, by default, doesn't provide storage, so always returns false
      def self.exists?(raw)
        false
      end

      def serialize
        hash               = self.as_json
        hash['actor']      = self.actor.as_json
        hash['repository'] = self.repository.as_json
        hash
      end
    end
  end
end