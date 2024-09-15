namespace :data do
  desc "Generate sample data"
  task generate: :environment do
    puts "Starting data generation..."
    result = DataGenerationService.generate_data(users_count: 10, posts_count: 50, interactions_count: 200)
    puts "Data generation complete!"
    puts "Generated #{result[:users].count} users, #{result[:posts].count} posts, and #{result[:interactions].count} interactions."
  end
end