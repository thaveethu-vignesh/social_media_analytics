require 'faker'

module DataGeneration
  class PostGenerator
    def self.generate(count = 1)
      users = User.all.to_a
      raise "No users found. Please generate users first." if users.empty?

      count.times.map do
        Post.create!(
          content: Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 3),
          user: users.sample,
          created_at: Faker::Time.between(from: 30.days.ago, to: Time.now)
        )
      end
    end
  end
end