class UserEngagementService
  def self.notify_followers(post)

    #not implemented the logic so just printing logs
    Rails.logger.info "Notifying followers of user #{post.user_id} about new post #{post.id}"
  end

  def self.update_user_score(user_id)
    post_count = REDIS_CLIENT.get("user:#{user_id}:post_count").to_i
    interaction_count = REDIS_CLIENT.get("user:#{user_id}:interaction_count").to_i

    score = calculate_score(post_count, interaction_count)
    REDIS_CLIENT.zadd("user_engagement_scores", score, user_id)
  end

  def self.get_top_engaged_users(limit = 10)
    REDIS_CLIENT.zrevrange("user_engagement_scores", 0, limit - 1, with_scores: true)
  end

  private

  def self.calculate_score(post_count, interaction_count)
    post_count * 10 + interaction_count
  end
end