module Frisky
  module Classifier
    module Hooks
      extend ActiveSupport::Concern

      module ClassMethods
        def hooks
          @hooks ||= Hash.new { |hash, key| hash[key] = [] }
        end

        def hook(event, trigger, args)
          @hooks ||= Hash.new { |hash, key| hash[key] = [] }
          @hooks[trigger] << args
          (@events ||= Array.new) << "#{event}_event".camelize
        end

        def events
          @events ||= Array.new
        end

        def on_push(*args)
          hook(:push, :push, args)
        end

        def on_follow(*args)
          hook(:follow, :follow, args)
        end
      end
    end
  end
end