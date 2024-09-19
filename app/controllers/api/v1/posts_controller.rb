module Api
  module V1
    class PostsController < BaseController
      def show
        post = PostRepository.find_post_by_id(params[:id])
        if post
          render json: post
        else
          render json: { error: 'Post not found' }, status: :not_found
        end
      end


    end
  end
end