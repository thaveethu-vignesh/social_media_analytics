class UserInfluenceService
  def self.calculate_user_influence(user_id)
    post_count = PostRepository.posts_by_user(user_id).count
    total_interactions = InteractionRepository.interactions_by_user(user_id).count

    influence_score = calculate_score(post_count, total_interactions)
    store_influence_score(user_id, influence_score)
    influence_score
  end

  def self.get_top_influencers(limit = 10)
    REDIS_CLIENT.zrevrange("user_influence_scores", 0, limit - 1, with_scores: true)
  end

  private

  def self.calculate_score(post_count, total_interactions)
    (post_count * 10 + total_interactions) / 100.0
  end

  def self.store_influence_score(user_id, score)
    REDIS_CLIENT.zadd("user_influence_scores", score, user_id)
  end
end