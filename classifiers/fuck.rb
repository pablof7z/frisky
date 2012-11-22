# This classifier marks commits with messages swearing, for fun and as a proof of concept
# would be cool to plug it with a realtime javascript framework to see a stream of fucks
# or to easily gather statistics of when/where/language people swear in

class FuckClassifier
  include Frisky::Classifier

  commit :commit

  class << self
    def commit_message_with_swear(commit)
      # Use bad_words gem
      return true if commit.message =~ /fuck/i
    end

    def commit(commit)
      return unless commit_message_with_swear? commit
    end
  end
end
