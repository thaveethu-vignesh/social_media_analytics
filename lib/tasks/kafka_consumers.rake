namespace :kafka do
  desc "Start all Kafka consumers"
  task start_consumers: :environment do
    threads = []
    
    threads << Thread.new do
      Rails.logger.info "Starting post consumer..."
      KafkaConsumerService.consume_posts
    end

    threads << Thread.new do
      Rails.logger.info "Starting interaction consumer..."
      KafkaConsumerService.consume_interactions
    end

    threads.each(&:join)
  end
end