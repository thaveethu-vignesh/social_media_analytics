namespace :kafka do
  desc "Start Kafka post consumer"
  task consume_posts: :environment do
    KafkaConsumerService.consume_posts
  end

  desc "Start Kafka interaction consumer"
  task consume_interactions: :environment do
    KafkaConsumerService.consume_interactions
  end
end