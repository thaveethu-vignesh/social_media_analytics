require 'faker'

module DataGeneration
  class InteractionGenerator
    INTERACTION_TYPES = %w[like share comment]

    def self.generate(count = 1)
      users = User.all.to_a
      posts = Post.all.to_a
      raise "No users or posts found. Please generate users and posts first." if users.empty? || posts.empty?

      count.times.map do
        Interaction.create!(
          interaction_type: INTERACTION_TYPES.sample,
          user: users.sample,
          post: posts.sample,
          created_at: Faker::Time.between(from: 30.days.ago, to: Time.now)
        )
      end
    end
  end
end