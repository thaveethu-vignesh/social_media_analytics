class TrendAnalysisService
  def self.analyze_post_trends(time_range = 7.days)
    start_time = time_range.ago
    posts = PostRepository.posts_since(start_time)

    posts_by_day = posts.group_by { |post| post.created_at.to_date }
    trend_data = posts_by_day.transform_values(&:count)

    store_trend_data("post_trends", trend_data)
    trend_data
  end

  def self.analyze_interaction_trends(time_range = 7.days)
    start_time = time_range.ago
    interactions = InteractionRepository.interactions_since(start_time)

    interactions_by_day = interactions.group_by { |interaction| interaction.created_at.to_date }
    trend_data = interactions_by_day.transform_values(&:count)

    store_trend_data("interaction_trends", trend_data)
    trend_data
  end

  def self.get_post_trends
    REDIS_CLIENT.hgetall("post_trends").transform_keys(&:to_date).transform_values(&:to_i)
  end

  def self.get_interaction_trends
    REDIS_CLIENT.hgetall("interaction_trends").transform_keys(&:to_date).transform_values(&:to_i)
  end

  private

  def self.store_trend_data(key, trend_data)
    REDIS_CLIENT.hmset(key, trend_data.to_a.flatten)
  end
end