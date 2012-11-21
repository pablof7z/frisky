module Frisky
  class << self
    attr_accessor :classifiers
  end

  @classifiers ||= {}

  module Classifier
    extend ActiveSupport::Concern

    autoload :Hooks, 'frisky/classifier/hooks'

    include Hooks

    def id; self.class.name; end

    included do
      extend Hooks
      # Register
      Frisky.classifiers[self.name] = self
    end
  end
end
