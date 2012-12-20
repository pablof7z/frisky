class FollowersNetwork
  include Frisky::Classifier

  on_follow :follow_handler

  # tag :following, {
  #     family: :network,
  #   category: :follow,

  # }

  def follow_handler follower, followed
    Frisky.log.info "follow_handler"
    # follower.tag :following, followed
  end
end