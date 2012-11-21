class CommitCountClassifier
  include Frisky::Classifier

  commit :update_commit_count, if: lambda {|commit| commit.files_type('Ruby').any? }

  class << self
    def update_commit_count(commit)
      puts "Received commit #{commit.id} for #{commit.repository.name}"
      # repository.increment(:commit_count, 1)
    end
  end
end
