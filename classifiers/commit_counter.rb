class CommitCounter
  include Frisky::Classifier

  on_push :update_push_count #, if: lambda {|commit| commit.files_type('Ruby').any? }

  def update_commit_count(commit)
    puts "Received commit #{commit.id} for #{commit.repository.name}"
    # repository.increment(:commit_count, 1)
  end
end
