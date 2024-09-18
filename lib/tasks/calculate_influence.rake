namespace :users do
  desc "Calculate influence for all users"
  task calculate_influence: :environment do
    CalculateAllUserInfluenceJob.new.perform
  end
end