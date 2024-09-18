class AnalyticsService

  REDIS_KEY_PREFIX = 'platform_stats:'
  
  def self.user_activity_summary(user_id)
    posts = PostRepository.posts_by_user(user_id)
    interactions = InteractionRepository.interactions_by_user(user_id)
    activity_by_hour = get_user_activity_by_hour(user_id)

    puts "activity_by_hour test #{activity_by_hour} "

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
  puts "interactions are #{interactions.inspect}"

  {
    post_id: post_id,
    total_interactions: interactions.count,
    interaction_types: interactions.group_by { |interaction| interaction[:interaction_type] }
                                   .transform_values(&:count)
  }
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

  def self.get_user_activity_by_hour(user_id)


    #need to check the right approach
    user_id_bigint = Cassandra::Types::Bigint.new(user_id)

    CassandraRepository.session.execute(
      "SELECT * FROM user_activity_by_hour WHERE user_id = ?",
      arguments: [user_id_bigint]
    )
  end

def self.find_most_active_hour(activity_by_hour)
  puts "Entering find_most_active_hour method"
  puts "activity_by_hour class: #{activity_by_hour.class}"
  puts "activity_by_hour count: #{activity_by_hour.count}"
  
  max_activity = nil
  max_hour = nil

  activity_by_hour.each do |row|
    puts "Processing row: #{row.inspect}"
    post_count = row['post_count'].to_i
    interaction_count = row['interaction_count'].to_i
    activity = post_count + interaction_count
    
    if max_activity.nil? || activity > max_activity
      max_activity = activity
      max_hour = row['activity_hour']
    end
  end

  puts "Max activity: #{max_activity}, Max hour: #{max_hour}"
  max_hour
end

end