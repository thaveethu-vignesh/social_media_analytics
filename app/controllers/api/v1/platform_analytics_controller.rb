module Api
  module V1
    class PlatformAnalyticsController < BaseController
      def overall_stats
        stats = AnalyticsService.overall_platform_stats
        render json: stats
      end

      def post_trends
        trends = TrendAnalysisService.get_post_trends
        render json: trends
      end

      def interaction_trends
        trends = TrendAnalysisService.get_interaction_trends
        render json: trends
      end
    end
  end
end