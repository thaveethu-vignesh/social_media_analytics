module Api
  module V1
    class PostAnalyticsController < BaseController
      def engagement
        engagement = AnalyticsService.post_engagement(params[:id])
        render json: engagement
      end
    end
  end
end