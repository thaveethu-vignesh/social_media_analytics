class ContentRecommendationService
  def self.update_post_score(post_id)
    interaction_count = REDIS_CLIENT.get("post:#{post_id}:interaction_count").to_i
    score = calculate_score(interaction_count)
    REDIS_CLIENT.zadd("popular_posts", score, post_id)
  end

  def self.get_popular_posts(limit = 10)
    REDIS_CLIENT.zrevrange("popular_posts", 0, limit - 1, with_scores: true)
  end

  private

  def self.calculate_score(interaction_count)
    2*interaction_count
  end
end