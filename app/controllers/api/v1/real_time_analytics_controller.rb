module Api
  module V1
    class RealTimeAnalyticsController < BaseController
      def trending_topics
        topics = TrendingTopicsService.get_trending_topics
        render json: topics
      end

      def popular_posts
        posts = ContentRecommendationService.get_popular_posts
        render json: posts
      end
    end
  end
end