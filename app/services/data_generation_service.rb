class DataGenerationService
  def self.generate_data(users_count: 10, posts_count: 50, interactions_count: 200)
    ActiveRecord::Base.transaction do
      Rails.logger.info "NEWW. Starting data generation: #{users_count} users, #{posts_count} posts, #{interactions_count} interactions"
      
      users = DataGeneration::UserGenerator.generate(users_count)
      Rails.logger.info "Generated #{users.count} users"
      
      posts = DataGeneration::PostGenerator.generate(posts_count)
      Rails.logger.info "Going for cassandra  posts"
      posts.each { |post| PostRepository.save(post) }
      Rails.logger.info "End for cassandra  posts"
      Rails.logger.info "Generated and saved #{posts.count} posts"
      
      interactions = DataGeneration::InteractionGenerator.generate(interactions_count)
      interactions.each { |interaction| InteractionRepository.save(interaction) }
      Rails.logger.info "Generated and saved #{interactions.count} interactions"

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