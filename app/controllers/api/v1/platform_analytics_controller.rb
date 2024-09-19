module Api
  module V1
    class PlatformAnalyticsController < BaseController
      def overall_stats
        stats = AnalyticsService.overall_platform_stats
        render json: stats
      end

      def post_trends
        trends = TrendingAnalysisService.get_post_trends
        render json: trends
      end

      def interaction_trends
        trends = TrendingAnalysisService.get_interaction_trends
        render json: trends
      end

      def generate_data
        users_count = params[:users_count] || 10
        posts_count = params[:posts_count] || 50
        interactions_count = params[:interactions_count] || 200

        result = DataGenerationService.generate_data(
          users_count: users_count.to_i,
          posts_count: posts_count.to_i,
          interactions_count: interactions_count.to_i
        )

        render json: { message: 'Data generated successfully', result: result }
      end
      
    end
  end
end