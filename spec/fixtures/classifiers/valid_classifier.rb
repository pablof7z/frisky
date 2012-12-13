class ValidClassifier
  include Frisky::Classifier

  on_commit :commit_handler

  def commit_handler
  end
end