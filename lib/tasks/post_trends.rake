namespace :trending do
  desc "Analyze post trends for the last 7 days"
  task analyze_post_trends: :environment do
    puts "Starting post trend analysis..."
    trend_data = TrendingAnalysisService.analyze_post_trends
    puts "Analysis complete. Trend data:"
    trend_data.each do |date, count|
      puts "#{date}: #{count} posts"
    end
  end

  desc "Analyze post trends for a custom time range"
  task :analyze_custom_range, [:days] => :environment do |t, args|
    days = args[:days].to_i
    puts "Starting post trend analysis for the last #{days} days..."
    trend_data = TrendingAnalysisService.analyze_post_trends(days.days)
    puts "Analysis complete. Trend data:"
    trend_data.each do |date, count|
      puts "#{date}: #{count} posts"
    end
  end

  desc "Analyze interaction trends for the last 7 days"
  task analyze_interaction_trends: :environment do
    puts "Starting analyze_post_trends analysis..."
    trend_data = TrendingAnalysisService.analyze_interaction_trends
    puts "Analysis complete. Trend data:"
    trend_data.each do |date, count|
      puts "#{date}: #{count} interactions"
    end
  end

end