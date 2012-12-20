module Frisky
  class << self
    attr_accessor :classifiers
  end

  @classifiers ||= {}

  # Module that provides core functionality for classifiers.
  #
  # Classifiers are Ruby classes that respond to mining asynchronous events.
  # Classifiers are stateless, since they can process related data in different nodes.
  #
  # Each classifier is responsible for announcing what type of events it wants to listen to,
  # and name the callbacks that it expects to receive.
  module Classifier
    extend ActiveSupport::Concern

    autoload :Hooks, 'frisky/classifier/hooks'
    autoload :Queue, 'frisky/classifier/queue'
    autoload :Keys,  'frisky/classifier/keys'

    include Hooks
    include Queue
    include Keys

    def id; self.class.name; end

    included do
      extend Hooks
      extend Queue
      extend Keys
    end
  end
end
