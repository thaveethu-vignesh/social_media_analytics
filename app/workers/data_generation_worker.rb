class DataGenerationWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3

  def perform(users_count, posts_count, interactions_count)
    begin
      DataGenerationService.generate_data(
        users_count: users_count,
        posts_count: posts_count,
        interactions_count: interactions_count
      )
    rescue => e
      Rails.logger.error "Data generation failed: #{e.message}"
      raise
    end
  end
end