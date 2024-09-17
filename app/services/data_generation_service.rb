class DataGenerationService
  def self.generate_data(users_count: 10, posts_count: 50, interactions_count: 200)
    ActiveRecord::Base.transaction do
      Rails.logger.info "Starting data generation: #{users_count} users, #{posts_count} posts, #{interactions_count} interactions"
      
      users = DataGeneration::UserGenerator.generate(users_count)
      Rails.logger.info "Generated #{users.count} users"
      
      posts = DataGeneration::PostGenerator.generate(posts_count)
      posts.each do |post| 
        # Saving post in both `posts` and `posts_by_time` tables
        PostRepository.save(post)
        # Producing the post event to Kafka
        KafkaProducerService.produce_post(post)
      end
      Rails.logger.info "Generated, saved, and produced #{posts.count} posts"
      
      interactions = DataGeneration::InteractionGenerator.generate(interactions_count)
      interactions.each do |interaction| 
        # Saving interaction in both `interactions` and `interactions_by_time` tables
        InteractionRepository.save(interaction)
        # Producing the interaction event to Kafka
        KafkaProducerService.produce_interaction(interaction)
      end
      Rails.logger.info "Generated, saved, and produced #{interactions.count} interactions"

      Rails.logger.info "Data generation complete"

      {
        users: users,
        posts: posts,
        interactions: interactions
      }
    end
  rescue StandardError => e
    Rails.logger.error "Data generation failed: #{e.message}"
    raise
  end
end
