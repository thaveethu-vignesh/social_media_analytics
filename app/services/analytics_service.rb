class AnalyticsService
  def self.user_activity_summary(user_id)
    posts = PostRepository.posts_by_user(user_id)
    interactions = InteractionRepository.interactions_by_user(user_id)

    {
      user_id: user_id,
      post_count: posts.count,
      interaction_count: interactions.count,
      interaction_types: interactions.group_by(&:interaction_type).transform_values(&:count)
    }
  end

  def self.post_engagement(post_id)
    interactions = InteractionRepository.interactions_for_post(post_id)

    {
      post_id: post_id,
      total_interactions: interactions.count,
      interaction_types: interactions.group_by(&:interaction_type).transform_values(&:count)
    }
  end
end