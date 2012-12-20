# This classifier identifies projects using cucumber (oh noooo!)
class CucumberTag
  include Frisky::Classifier

  on_push :push_handler

  def self.push_handler repository, push_event
    push_event.commits.each do |commit|
      author = commit.author

      Frisky.log.info "Commit by [%10s] - [%40s]" % [commit.author.name[0..9], commit.message[0..39]]
    end
  end
end
