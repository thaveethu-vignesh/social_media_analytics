class RealTimeAnalyticsService
  def self.process_new_post(post)
    update_post_count(post.user_id)
    update_hourly_post_rate
    puts "Realtime process_new_post is done"
  end

  def self.process_new_interaction(interaction)
    update_interaction_count(interaction.user_id, interaction.post_id)
    update_hourly_interaction_rate
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
end