module Api
  module V1
    class UserAnalyticsController < BaseController
      def activity_summary
        summary = AnalyticsService.user_activity_summary(params[:id])
        render json: summary
      end

      def top_influencers
        influencers = UserInfluenceService.get_top_influencers
        render json: influencers
      end
    end
  end
end