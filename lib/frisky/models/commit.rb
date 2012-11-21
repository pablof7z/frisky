module Frisky
  module Model
    class Commit
      include MongoMapper::Document

      key :author_id, ObjectId
      key :message, String
      key :sha, String
      key :repository_id, ObjectId

      belongs_to :author, class_name: 'Frisky::Model::Author'
      belongs_to :repository, class_name: 'Frisky::Model::Repository'
    end
  end
end