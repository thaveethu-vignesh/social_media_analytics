class PostRepository < CassandraRepository
  def self.save(post)
    session.execute(
      "INSERT INTO posts (id, user_id, content, created_at) VALUES (?, ?, ?, ?)",
      arguments: [post.id, post.user_id, post.content, post.created_at]
    )
  end

  def self.find(id)
    result = session.execute("SELECT * FROM posts WHERE id = ?", arguments: [id]).first
    return nil unless result

    Post.new(
      id: result['id'],
      user_id: result['user_id'],
      content: result['content'],
      created_at: result['created_at']
    )
  end
end