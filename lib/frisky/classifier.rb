module Frisky
  module Classifier
    extend ActiveSupport::Concern

    autoload :Hooks, 'frisky/classifier/hooks'

    include Hooks

    def id; self.class.name; end

    included do
      extend Hooks
    end
  end
end
