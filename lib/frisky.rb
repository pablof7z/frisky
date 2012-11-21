require "active_support/core_ext"


require 'frisky/config'

require 'frisky/models/author'
require 'frisky/models/commit'
require 'frisky/models/event'
require 'frisky/models/repository'

module Frisky
  autoload :Classifier, 'frisky/classifier'
  autoload :Version,    'frisky/version'
end

ActiveSupport.run_load_hooks(:frisky, Frisky)