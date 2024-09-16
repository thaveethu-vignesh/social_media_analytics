class AnalyticsService
  def self.user_activity_summary(user_id)
    posts = PostRepository.posts_by_user(user_id)
    interactions = InteractionRepository.interactions_by_user(user_id)
    activity_by_hour = get_user_activity_by_hour(user_id)

    {
      user_id: user_id,
      post_count: posts.count,
      interaction_count: interactions.count,
      interaction_types: interactions.group_by(&:interaction_type).transform_values(&:count),
      average_interactions_per_post: (interactions.count.to_f / posts.count).round(2),
      most_active_hour: find_most_active_hour(activity_by_hour)
    }
  end

  def self.post_engagement(post_id)
    interactions = InteractionRepository.interactions_by_post(post_id)

    {
      post_id: post_id,
      total_interactions: interactions.count,
      interaction_types: interactions.group_by(&:interaction_type).transform_values(&:count)
    }
  end

  def self.overall_platform_stats
    result = CassandraRepository.session.execute(
      "SELECT * FROM platform_stats WHERE stat_date = ?",
      arguments: [Date.today]
    ).first

    {
      total_users: result['total_users'],
      total_posts: result['total_posts'],
      total_interactions: result['total_interactions'],
      average_posts_per_user: (result['total_posts'].to_f / result['total_users']).round(2),
      average_interactions_per_post: (result['total_interactions'].to_f / result['total_posts']).round(2)
    }
  end

  private

  def self.get_user_activity_by_hour(user_id)
    CassandraRepository.session.execute(
      "SELECT * FROM user_activity_by_hour WHERE user_id = ?",
      arguments: [user_id]
    )
  end

  def self.find_most_active_hour(activity_by_hour)
    activity_by_hour.max_by { |row| row['post_count'] + row['interaction_count'] }&.[]('activity_hour')
  end
end