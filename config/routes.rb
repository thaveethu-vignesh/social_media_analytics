Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # User Analytics
      resources :user_analytics, only: [] do
        collection do
          get 'top_influencers'
        end
        member do
          get 'activity_summary'
        end
      end


      resources :posts, only: [:show]

      # Post Analytics
      resources :post_analytics, only: [] do
        member do
          get 'engagement'
        end
      end

      # Platform Analytics
      namespace :platform_analytics do
        get 'overall_stats'
        get 'post_trends'
        get 'interaction_trends'
        post 'generate_data'
      end

      # Real-time Analytics
      namespace :real_time_analytics do
        get 'trending_topics'
        get 'popular_posts'
      end

      # Data Generation (for testing purposes)
      post 'generate_data', to: 'data_generation#create'
    end
  end

  get 'dashboard/index'
  root 'home#index'
  post 'data_generate', to: 'dashboard#data_generate'
  devise_for :users

  # Mount Swagger UI
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
end