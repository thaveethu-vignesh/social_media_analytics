# app/jobs/calculate_all_user_influence_job.rb

class CalculateAllUserInfluenceJob
  include Sidekiq::Job

  def perform
    User.find_each do |user|
      CalculateUserInfluenceJob.perform_async(user.id)
    end
  end
end