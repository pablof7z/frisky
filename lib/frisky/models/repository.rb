module Frisky
  module Model
    class Repository
      include MongoMapper::Document

      key :url, String
      key :name, String
    end
  end
end