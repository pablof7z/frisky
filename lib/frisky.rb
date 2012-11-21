require "active_support/core_ext"


require 'frisky/config'
module Frisky
  autoload :Classifier, 'frisky/classifier'
  autoload :Version,    'frisky/version'
end

ActiveSupport.run_load_hooks(:frisky, Frisky)