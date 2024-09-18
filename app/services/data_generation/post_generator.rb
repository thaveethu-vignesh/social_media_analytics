require 'faker'

module DataGeneration
  class PostGenerator
    def self.generate(count = 1, batch_size = 50)
      total_users = User.count
      raise "No users found. Please generate users first." if total_users.zero?

      posts = []
      post_response=[]
      count.times do
        offset = rand(total_users)
        user = User.offset(offset).first

        post = Post.new(
          content: Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 3),
          user: user,
          created_at: Faker::Time.between(from: 30.days.ago, to: Time.now)
        )

        if posts.size >= batch_size
          Post.import posts
          posts = []
        end
        posts << post
        post_response << post
      end

      Post.import posts if posts.any?
      post_response
    end
  end
end