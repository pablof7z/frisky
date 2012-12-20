module Frisky
  module Classifier
    module Keys
      extend ActiveSupport::Concern

      module ClassMethods
        # Provides the appropriate redis key for different configurations of each classifier
        def key(type)
          raise NameError unless %w(events).include? type.to_s
          "classifier:#{self.name}:config:#{type}"
        end
      end
    end
  end
end