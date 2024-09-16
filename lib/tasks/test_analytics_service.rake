# lib/tasks/test_analytics_service.rake

namespace :analytics do
  desc "Test AnalyticsService functionality"
  task test: :environment do
    puts "Rails.env: #{Rails.env}"
    puts "ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"

    puts "\nTesting AnalyticsService..."

    begin
      # Ensure we have some test data
      user = User.first || User.create!(name: "Test User", email: "test@example.com", password: "password123")
      post = Post.first || Post.create!(user: user, content: "Test post content")
      Interaction.create!(user: user, post: post, interaction_type: "like") unless Interaction.exists?

      puts "\nTesting user_activity_summary..."
      summary = AnalyticsService.user_activity_summary(user.id)
      puts "User Activity Summary: #{summary.inspect}"

      puts "\nTesting post_engagement..."
      engagement = AnalyticsService.post_engagement(post.id)
      puts "Post Engagement: #{engagement.inspect}"

      puts "\nTesting overall_platform_stats..."
      stats = AnalyticsService.overall_platform_stats
      puts "Overall Platform Stats: #{stats.inspect}"

      # Test other AnalyticsService methods here...

      puts "\nAll AnalyticsService tests completed successfully."
    rescue => e
      puts "Error during AnalyticsService testing: #{e.class.name} - #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end