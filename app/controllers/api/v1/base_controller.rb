module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      
      before_action :authenticate_request
      before_action :set_request_start_time
      after_action :log_request_details
      around_action :catch_exceptions
      
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActionController::ParameterMissing, with: :bad_request

      private

      def authenticate_request
        auth_token = params[:auth_token]
        unless valid_auth_token?(auth_token)
          render_error('Invalid or missing auth token', :unauthorized)
        end
      end

      def valid_auth_token?(token)
        token.present? && token == '12345'
      end

      def set_request_start_time
        @request_start_time = Time.current
      end

      def log_request_details
        duration = Time.current - @request_start_time
        Rails.logger.info("Request to #{request.path} took #{duration} seconds")
      end

      def catch_exceptions
        yield
      rescue StandardError => e
        Rails.logger.error("Error in #{controller_name}##{action_name}: #{e.message}")
        render_error('An unexpected error occurred', :internal_server_error)
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