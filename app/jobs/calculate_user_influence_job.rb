class CalculateUserInfluenceJob
  include Sidekiq::Job

  def perform(user_id)
    UserInfluenceService.calculate_user_influence(user_id)
  end
end