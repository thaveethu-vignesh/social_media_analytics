class RealTimeAnalyticsService
  REDIS_KEY_PREFIX = "platform_stats:"

  def self.process_new_post(post)
    update_post_count(post.user_id)
    update_hourly_post_rate
    update_daily_stats(:posts)
    update_daily_stats(:users, post.user_id)
    puts "Realtime process_new_post is done"
  end

  def self.process_new_interaction(interaction)
    puts "process_new_interaction called #{interaction.inspect}"
    update_interaction_count(interaction.user_id, interaction.post_id)
    update_hourly_interaction_rate
    update_daily_stats(:interactions)
    update_daily_stats(:users, interaction.user_id)
  end

  def self.overall_platform_stats
    timestamp = Time.now
    day_key = timestamp.strftime("%Y%m%d")
    
    puts "Fetching platform stats for day: #{day_key}"
    
    total_users = REDIS_CLIENT.get("#{REDIS_KEY_PREFIX}#{day_key}:total_users").to_i
    total_posts = REDIS_CLIENT.get("#{REDIS_KEY_PREFIX}#{day_key}:total_posts").to_i
    total_interactions = REDIS_CLIENT.get("#{REDIS_KEY_PREFIX}#{day_key}:total_interactions").to_i
    
    puts "Total users: #{total_users}"
    puts "Total posts: #{total_posts}"
    puts "Total interactions: #{total_interactions}"
    
    average_posts_per_user = total_users.zero? ? 0 : (total_posts.to_f / total_users).round(2)
    average_interactions_per_post = total_posts.zero? ? 0 : (total_interactions.to_f / total_posts).round(2)
    
    puts "Average posts per user: #{average_posts_per_user}"
    puts "Average interactions per post: #{average_interactions_per_post}"
    
    {
      total_users: total_users,
      total_posts: total_posts,
      total_interactions: total_interactions,
      average_posts_per_user: average_posts_per_user,
      average_interactions_per_post: average_interactions_per_post
    }
  end

  private

  def self.update_post_count(user_id)
    puts "update_post_count key is user:#{user_id}:post_count"
    REDIS_CLIENT.incr("user:#{user_id}:post_count")
  end

  def self.update_hourly_post_rate
    current_hour = Time.now.strftime("%Y%m%d%H")
    REDIS_CLIENT.incr("hourly_post_rate:#{current_hour}")
  end

  def self.update_interaction_count(user_id, post_id)
    REDIS_CLIENT.incr("user:#{user_id}:interaction_count")
    REDIS_CLIENT.incr("post:#{post_id}:interaction_count")
  end

  def self.update_hourly_interaction_rate
    current_hour = Time.now.strftime("%Y%m%d%H")
    REDIS_CLIENT.incr("hourly_interaction_rate:#{current_hour}")
  end

def self.update_daily_stats(type, user_id = nil)
    day_key = Time.now.strftime("%Y%m%d")
    
    case type
    when :posts
      REDIS_CLIENT.incr("#{REDIS_KEY_PREFIX}#{day_key}:total_posts")
    when :interactions
      REDIS_CLIENT.incr("#{REDIS_KEY_PREFIX}#{day_key}:total_interactions")
    when :users
      if REDIS_CLIENT.sadd?("#{REDIS_KEY_PREFIX}#{day_key}:unique_users", user_id)
        REDIS_CLIENT.incr("#{REDIS_KEY_PREFIX}#{day_key}:total_users")
      end
    end
end
end