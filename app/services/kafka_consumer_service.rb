class KafkaConsumerService
  def self.consume_posts

    puts "data consumer called successfully"
    consumer = KAFKA_CLIENT.consumer(group_id: 'post_consumers')
    consumer.subscribe('posts')

    consumer.each_message do |message|

      puts "looping messages #{message}"
      process_post(message)
    end
  end

  def self.consume_interactions
    consumer = KAFKA_CLIENT.consumer(group_id: 'interaction_consumers')
    consumer.subscribe('interactions')

    consumer.each_message do |message|
      process_interaction(message)
    end
  end

  private

  def self.process_post(message)
    data = JSON.parse(message.value)
    post = Post.new(
      id: data['id'],
      user_id: data['user_id'],
      content: data['content'],
      created_at: data['created_at']
    )

    puts "Gonna process consumed messages #{message}"

    RealTimeAnalyticsService.process_new_post(post)
    TrendingTopicsService.update_topics(post)
    UserEngagementService.notify_followers(post)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse post message: #{e.message}"
  end

  def self.process_interaction(message)
    data = JSON.parse(message.value)
    interaction = Interaction.new(
      id: data['id'],
      user_id: data['user_id'],
      post_id: data['post_id'],
      interaction_type: data['interaction_type'],
      created_at: data['created_at']
    )

    RealTimeAnalyticsService.process_new_interaction(interaction)
    UserEngagementService.update_user_score(interaction.user_id)
    ContentRecommendationService.update_post_score(interaction.post_id)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse interaction message: #{e.message}"
  end
end