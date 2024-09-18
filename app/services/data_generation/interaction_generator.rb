require 'faker'

module DataGeneration
  class InteractionGenerator
    INTERACTION_TYPES = %w[like share comment]

    def self.generate(count = 1, batch_size = 1000)
      total_users = User.count
      total_posts = Post.count
      raise "No users or posts found. Please generate users and posts first." if total_users.zero? || total_posts.zero?

      interactions = []
      interactions_response = []
      count.times do
        user = User.offset(rand(total_users)).first
        post = Post.offset(rand(total_posts)).first

        interaction = Interaction.new(
          interaction_type: INTERACTION_TYPES.sample,
          user: user,
          post: post,
          created_at: Faker::Time.between(from: 30.days.ago, to: Time.now)
        )

        if interactions.size >= batch_size
          Interaction.import interactions
          interactions = []
        end

        interactions << interaction
        interactions_response << interaction
      end

      Interaction.import interactions if interactions.any?
      interactions
    end
  end
end