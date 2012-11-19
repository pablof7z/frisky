require "active_support/core_ext"

module Frisky
  autoload :Config,     'frisky/config'
  autoload :Classifier, 'frisky/classifier'
  autoload :Version,    'frisky/version'
end

ActiveSupport.run_load_hooks(:frisky, Frisky)