class TrendingTopicsService
  def self.update_topics(post)
    topics = extract_topics(post.content)
    current_hour = Time.now.strftime("%Y%m%d%H")

    topics.each do |topic|
      REDIS_CLIENT.zincrby("trending_topics:#{current_hour}", 1, topic)
    end
  end

  def self.get_trending_topics(limit = 10)
    current_hour = Time.now.strftime("%Y%m%d%H")
    REDIS_CLIENT.zrevrange("trending_topics:#{current_hour}", 0, limit - 1, with_scores: true)
  end

  private

  def self.extract_topics(content)
    content.scan(/#\w+/).map(&:downcase).uniq
  end
end