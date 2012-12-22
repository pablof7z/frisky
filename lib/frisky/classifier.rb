require 'frisky/classifier/hooks'
require 'frisky/classifier/queue'
require 'frisky/classifier/keys'

module Frisky
  # Module that provides core functionality for classifiers.
  #
  # Classifiers are Ruby classes that respond to mining asynchronous events.
  # Classifiers are stateless, since they can process related data in different nodes.
  #
  # Each classifier is responsible for announcing what type of events it wants to listen to,
  # and name the callbacks that it expects to receive.
  module Classifier
    extend ActiveSupport::Concern

    included do
      include Hooks
      include Queue
      include Keys
    end
  end
end
