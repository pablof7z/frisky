require "active_support/core_ext"

require 'frisky/helpers/github'

require 'frisky/config'

require 'frisky/models/author'
require 'frisky/models/commit'
require 'frisky/models/event'
require 'frisky/models/repository'

require 'frisky/helpers/lock'
require 'frisky/errors'

module Frisky
  autoload :Classifier, 'frisky/classifier'
  autoload :Version,    'frisky/version'
end

ActiveSupport.run_load_hooks(:frisky, Frisky)