# This classifier identifies projects using cucumber (oh noooo!) and tags them appropriately
# as dhh-hates-it
class CucumberTag
  include Frisky::Classifier

  on_push :push_handler, unless: lambda { |repo| repo.tagged? Cucumber }

  # tag :dhh_hates_it {
  #    family: :opinions
  #   subject: :dhh,
  #      type: :dislikes,
  # }

  # tag :cucumber {
  #     family: :technology,
  #   category: :testing,
  #       tags: :dhh_hates_it
  # }

  def push_handler repo, push
    push.commits do |commit|
      next if commit.merge?

      author = commit.author

      commit.each_file do |file|
        begin
          if Pathname.new(file.filename).split.first.to_s == 'features'
            repo.tag CucumberTag
          end
        rescue StandardError => e
          Frisky.logger.warn e.message
        end
      end
    end
  end
end

# class CucumberTag < Frisky::Tag
#   family   :technology
#   category :testing

#   tags     :dhh_hates_it
# end

# class DhhHatesIt < Frisky::Tag
#   family   :opinions
#   subject  :dhh
#   type     :dislikes
# end
