# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# Create users
user1 = User.create!(name: "John Doe", email: "john@example.com", password: "password")
user2 = User.create!(name: "Jane Smith", email: "jane@example.com", password: "password")

# Create posts
post1 = Post.create!(content: "Hello, world!", user: user1)
post2 = Post.create!(content: "Ruby on Rails is awesome!", user: user2)

# Create interactions
Interaction.create!(interaction_type: "like", user: user2, post: post1)
Interaction.create!(interaction_type: "comment", user: user1, post: post2)