# lib/tasks/test_analytics.rake

namespace :analytics do
  desc "Test analytics implementation"
  task test: :environment do
    puts "Rails.env: #{Rails.env}"
    puts "ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"

    # Fetch the latest user (by created_at or id, assuming higher id = latest)
    latest_user = User.order(created_at: :desc).first

    if latest_user
      puts "User object: #{latest_user.inspect}"
      puts "\nTesting user_activity_summary with latest user... ID  #{latest_user.id}"
      summary = AnalyticsService.user_activity_summary(latest_user.id)
      puts summary.inspect

      puts "\nTesting post_engagement with the latest user's post..."
      post = PostRepository.posts_by_user(latest_user.id, 1).first
      if post
        engagement = AnalyticsService.post_engagement(post.id)
        puts engagement.inspect
      else
        puts "No posts found for the latest user."
      end

      puts "\nTesting overall_platform_stats..."
      stats = AnalyticsService.overall_platform_stats
      puts stats.inspect

      puts "\nAnalytics tests completed."
    else
      puts "No users found in the database."
    end
  end
end
