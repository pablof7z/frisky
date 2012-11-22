module Frisky
  module Classifier
    module Hooks
      extend ActiveSupport::Concern

      module ClassMethods
        def inherited(descendant)
          descendant.instance_variable_set(:@hooks, hooks.dup)
          super
        end

        def hooks
          @hooks ||= Hash.new { |hash, key| hash[key] = [] }
        end

        def hook(trigger, args)
          @hooks ||= Hash.new { |hash, key| hash[key] = [] }
          @hooks[trigger] << args
        end

        def commit(*args); hook(:commit, args); end
        def finalize(*args); hook(:commit, args); end
      end
    end
  end
end