module Frisky
  module Model
    class Author
      include ::MongoMapper::Document

      key :name, String
      key :email, String
    end
  end
end