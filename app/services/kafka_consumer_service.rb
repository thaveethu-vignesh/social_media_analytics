class KafkaConsumerService
  def self.consume_posts
    consumer = KAFKA_CLIENT.consumer(group_id: 'post_consumers')
    consumer.subscribe('posts')

    consumer.each_message do |message|
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
    
    Rails.logger.info "Processed post: #{data['id']}"
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse post message: #{e.message}"
  end

  def self.process_interaction(message)
    data = JSON.parse(message.value)
    
    Rails.logger.info "Processed interaction: #{data['id']}"
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse interaction message: #{e.message}"
  end
end