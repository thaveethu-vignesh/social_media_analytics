class PostRepository < CassandraRepository
  def self.save(post)
    session.execute(
      "INSERT INTO posts_by_user (user_id, post_id, content, created_at) VALUES (?, ?, ?, ?)",
      arguments: [post.user_id, post.id, post.content, post.created_at]
    )
    increment_counter("platform_stats", "total_posts", 1)
    increment_user_activity(post.user_id, post.created_at, :post)
  end

  def self.find(user_id, post_id)
    result = session.execute(
      "SELECT * FROM posts_by_user WHERE user_id = ? AND post_id = ?",
      arguments: [user_id, post_id]
    ).first
    build_post(result) if result
  end

  def self.posts_by_user(user_id, limit = 10)
    results = session.execute(
      "SELECT * FROM posts_by_user WHERE user_id = ? LIMIT ?",
      arguments: [user_id, limit]
    )
    results.map { |row| build_post(row) }
  end

  private

  def self.build_post(row)
    Post.new(
      id: row['post_id'],
      user_id: row['user_id'],
      content: row['content'],
      created_at: row['created_at']
    )
  end

  def self.increment_counter(table, column, value = 1)
    session.execute(
      "UPDATE #{table} SET #{column} = #{column} + ? WHERE stat_date = ?",
      arguments: [value, Date.today]
    )
  end

  def self.increment_user_activity(user_id, timestamp, activity_type)
    hour = timestamp.beginning_of_hour
    column = activity_type == :post ? 'post_count' : 'interaction_count'
    session.execute(
      "UPDATE user_activity_by_hour SET #{column} = #{column} + 1 WHERE user_id = ? AND activity_hour = ?",
      arguments: [user_id, hour]
    )
  end
end