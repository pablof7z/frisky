module Frisky
  class << self
    attr_accessor :classifiers

    def reset_classifiers!
      # Undefine classes
      @classifiers.keys.each {|klass| Object.send(:remove_const, klass.to_sym)}

      # Remove all keys
      @classifiers.clear
    end
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
