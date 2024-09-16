# lib/tasks/test_analytics.rake

namespace :analytics do
  desc "Test analytics implementation"
  task test: :environment do
    puts "Rails.env: #{Rails.env}"
    puts "ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"

    puts "\nGenerating test data..."
    user = User.create!(name: "Test User", email: "test@example.com", password: "password123")
    5.times do |i|
      post = Post.new(user: user, content: "Test post #{i}", created_at: i.hours.ago)
      post.save
      PostRepository.save(post)
      3.times do |j|
        interaction = Interaction.new(user: user, post: post, interaction_type: ['like', 'comment', 'share'].sample, created_at: i.hours.ago + j.minutes)
        interaction.save
        InteractionRepository.save(interaction)
      end
    end

    puts "\nTesting user_activity_summary..."
    summary = AnalyticsService.user_activity_summary(user.id)
    puts summary.inspect

    puts "\nTesting post_engagement..."
    post = PostRepository.posts_by_user(user.id, 1).first
    engagement = AnalyticsService.post_engagement(post.id)
    puts engagement.inspect

    puts "\nTesting overall_platform_stats..."
    stats = AnalyticsService.overall_platform_stats
    puts stats.inspect

    puts "\nAnalytics tests completed."
  end
end