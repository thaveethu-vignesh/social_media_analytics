require 'kafka'

KAFKA_CLIENT = Kafka.new(
  seed_brokers: ['localhost:9092'],
  client_id: 'social_media_analytics'
)