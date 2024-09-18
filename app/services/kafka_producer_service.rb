class KafkaProducerService
  KAFKA_TOPICS = {
    post: 'posts',
    interaction: 'interactions'
  }

  def self.produce_post(post)
    message = {
      id: post.id,
      user_id: post.user_id,
      content: post.content,
      created_at: post.created_at
    }.to_json

    produce_message(KAFKA_TOPICS[:post], message)
  end

  def self.produce_interaction(interaction)
    message = {
      id: interaction.id,
      user_id: interaction.user_id,
      post_id: interaction.post_id,
      interaction_type: interaction.interaction_type,
      created_at: interaction.created_at
    }.to_json

    produce_message(KAFKA_TOPICS[:interaction], message)
  end

  private

  def self.produce_message(topic, message)
    KAFKA_CLIENT.deliver_message(message, topic: topic)
    puts "Kafka produce success #{message} "
  rescue Kafka::Error => e
    Rails.logger.error "Failed to produce Kafka message: #{e.message} and msg #{message}"
  end
end