class DashboardController < ApplicationController
  def index
    @user_count = User.count
    @post_count = Post.count
    @interaction_count = Interaction.count
    @last_generation = DataGenerationWorker.perform_in(1.minute, 1, 5, 10)  # Schedule a small job
  end

  def data_generate
    # Trigger a data generation task here
    DataGenerationWorker.perform_async(10, 50, 100)

    # Redirect back to the dashboard or show a success message
    redirect_to dashboard_index_path, notice: 'Data generation has been triggered!'
  end

end