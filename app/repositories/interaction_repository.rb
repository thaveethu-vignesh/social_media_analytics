class InteractionRepository < CassandraRepository
  def self.save(interaction)
    session.execute(
      "INSERT INTO interactions_by_user (user_id, interaction_id, post_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?)",
      arguments: [interaction.user_id, interaction.id, interaction.post_id, interaction.interaction_type, interaction.created_at]
    )
    session.execute(
      "INSERT INTO interactions_by_post (post_id, interaction_id, user_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?)",
      arguments: [interaction.post_id, interaction.id, interaction.user_id, interaction.interaction_type, interaction.created_at]
    )
    increment_counter("platform_stats", "total_interactions", 1)
    increment_user_activity(interaction.user_id, interaction.created_at, :interaction)
  end

  def self.interactions_by_user(user_id, limit = 100)
    results = session.execute(
      "SELECT * FROM interactions_by_user WHERE user_id = ? LIMIT ?",
      arguments: [user_id, limit]
    )
    results.map { |row| build_interaction(row) }
  end

  def self.interactions_by_post(post_id, limit = 100)
    results = session.execute(
      "SELECT * FROM interactions_by_post WHERE post_id = ? LIMIT ?",
      arguments: [post_id, limit]
    )
    results.map { |row| build_interaction(row) }
  end

  private

  def self.build_interaction(row)
    Interaction.new(
      id: row['interaction_id'],
      user_id: row['user_id'],
      post_id: row['post_id'],
      interaction_type: row['interaction_type'],
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