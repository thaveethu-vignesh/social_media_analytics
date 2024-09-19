namespace :trending do
  desc "Analyze post trends for the last 7 days"
  task analyze_post_trends: :environment do
    puts "Starting post trend analysis..."
    trend_data = TrendingTopicsService.update_topics
    puts "Analysis complete. Trend data:"
    trend_data.each do |date, count|
      puts "#{date}: #{count} posts"
    end
  end

end