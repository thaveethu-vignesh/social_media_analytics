class InteractionRepository < CassandraRepository
  CACHE_EXPIRATION = 1.hour

  def self.save(interaction)
    session.execute(
      "INSERT INTO interactions (id, user_id, post_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?)",
      arguments: [interaction.id, interaction.user_id, interaction.post_id, interaction.interaction_type, interaction.created_at]
    )
    cache_set(interaction)
  end

  def self.find(id)
    cached = cache_get(id)
    return cached if cached

    result = session.execute("SELECT * FROM interactions WHERE id = ?", arguments: [id]).first
    return nil unless result

    interaction = Interaction.new(
      id: result['id'],
      user_id: result['user_id'],
      post_id: result['post_id'],
      interaction_type: result['interaction_type'],
      created_at: result['created_at']
    )

    cache_set(interaction)
    interaction
  end


  def self.interactions_for_post(post_id, limit = 100)
    results = session.execute("SELECT * FROM interactions WHERE post_id = ? LIMIT ?", arguments: [post_id, limit])
    results.map do |row|
      Interaction.new(
        id: row['id'],
        user_id: row['user_id'],
        post_id: row['post_id'],
        interaction_type: row['interaction_type'],
        created_at: row['created_at']
      )
    end
  end

  def self.interactions_by_user(user_id, limit = 100)
    results = session.execute("SELECT * FROM interactions WHERE user_id = ? LIMIT ?", arguments: [user_id, limit])
    results.map do |row|
      Interaction.new(
        id: row['id'],
        user_id: row['user_id'],
        post_id: row['post_id'],
        interaction_type: row['interaction_type'],
        created_at: row['created_at']
      )

    end
  end

  private

  def self.cache_key(id)
    "interaction:#{id}"
  end

  def self.cache_set(interaction)
    REDIS_CLIENT.setex(cache_key(interaction.id), CACHE_EXPIRATION, interaction.to_json)
  end

  def self.cache_get(id)
    cached = REDIS_CLIENT.get(cache_key(id))
    return nil unless cached

    data = JSON.parse(cached)
    Interaction.new(
      id: data['id'],
      user_id: data['user_id'],
      post_id: data['post_id'],
      interaction_type: data['interaction_type'],
      created_at: data['created_at']
    )
  end
end