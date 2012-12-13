require 'json'

module Frisky
  module Model
    class Event
      include MongoMapper::Document

      key :type, String

      many :commits, class_name: 'Frisky::Model::Commit'

      def serialize; self.to_json; end

      def initialize(*args)
        super

        # Load repo
        if self['repo']
          repository = Frisky::Model::Repository.first_or_new(url: self['repo']['url'])

          if repository.new?
            repository.id   = self['repo']['id']
            repository.name = self['repo']['name']
            repository.save!
          end
        end

        # Load commits
        (self['payload']['commits']||[]).each do |commit_hash|
          commit = ::Frisky::Model::Commit.first_or_new(sha: commit_hash['sha'])
          if commit.new?
            author_hash       = commit_hash['author']

            commit.sha        = commit_hash['sha']
            commit.author     = Frisky::Model::Author.first_or_new(name: author_hash['name'], email: author_hash['email'])
            commit.message    = commit_hash['message']
            commit.repository = repository
          end

          self.commits << commit
        end
      end

      # Checks if an event exists in the database using @type and @id keys
      def self.exists?(event_hash)
        self.collection.find_one(type: event_hash['type'], _id: event_hash['id']) != nil
      end
    end
  end
end