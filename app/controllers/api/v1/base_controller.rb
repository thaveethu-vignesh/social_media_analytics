module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_request

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActionController::ParameterMissing, with: :bad_request

      private

      def authenticate_request
        #can implement auth here
        true
      end

      def not_found
        render_error('Record not found', :not_found)
      end

      def bad_request(exception)
        render_error(exception.message, :bad_request)
      end

      def render_error(message, status)
        render json: { error: message }, status: status
      end
    end
  end
end