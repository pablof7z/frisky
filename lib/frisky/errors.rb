module Frisky
  class InvalidClassName < StandardError; end
  class NotImplemented < StandardError; end
  class ApiRateLimitReached < StandardError; end
  class IncompatibleDataStructure < StandardError; end
end