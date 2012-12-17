require "active_support/core_ext"

require 'frisky/config'

require 'frisky/models/proxy_base'
require 'frisky/models/person'
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

# After loading all the models, see if there are extensions
if defined? Frisky::Model::EXTENSIONS
  Frisky::Model::EXTENSIONS.each {|file| require file }
end