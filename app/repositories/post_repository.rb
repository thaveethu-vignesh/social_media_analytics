class PostRepository < CassandraRepository
  CACHE_EXPIRATION = 1.hour

  def self.save(post)
    session.execute(
      "INSERT INTO posts (id, user_id, content, created_at) VALUES (?, ?, ?, ?)",
      arguments: [post.id, post.user_id, post.content, post.created_at]
    )
    cache_set(post)
  end

  def self.find(id)
    cached = cache_get(id)
    return cached if cached

    result = session.execute("SELECT * FROM posts WHERE id = ?", arguments: [id]).first
    return nil unless result

    post = Post.new(
      id: result['id'],
      user_id: result['user_id'],
      content: result['content'],
      created_at: result['created_at']
    )

    cache_set(post)
    post
  end


  def self.recent_posts(limit = 10)
    results = session.execute("SELECT * FROM posts ORDER BY created_at DESC LIMIT ?", arguments: [limit])
    results.map do |row|
      Post.new(
        id: row['id'],
        user_id: row['user_id'],
        content: row['content'],
        created_at: row['created_at']
      )
    end
  end

  def self.posts_by_user(user_id, limit = 10)
    results = session.execute("SELECT * FROM posts WHERE user_id = ? LIMIT ?", arguments: [user_id, limit])
    results.map do |row|
      Post.new(
        id: row['id'],
        user_id: row['user_id'],
        content: row['content'],
        created_at: row['created_at']
      )
    end
  end

  private

  def self.cache_key(id)
    "post:#{id}"
  end

  def self.cache_set(post)
    REDIS_CLIENT.setex(cache_key(post.id), CACHE_EXPIRATION, post.to_json)
  end

  def self.cache_get(id)
    cached = REDIS_CLIENT.get(cache_key(id))
    return nil unless cached

    data = JSON.parse(cached)
    Post.new(
      id: data['id'],
      user_id: data['user_id'],
      content: data['content'],
      created_at: data['created_at']
    )
  end
end