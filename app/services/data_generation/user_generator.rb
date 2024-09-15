require 'faker'

module DataGeneration
  class UserGenerator
    def self.generate(count = 1)
      count.times.map do
        User.create!(
          name: Faker::Name.name,
          email: Faker::Internet.unique.email,
          password: 'password123'
        )
      end
    end
  end
end