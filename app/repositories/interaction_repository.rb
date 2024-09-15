class InteractionRepository < CassandraRepository
  def self.save(interaction)
    session.execute(
      "INSERT INTO interactions (id, user_id, post_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?)",
      arguments: [interaction.id, interaction.user_id, interaction.post_id, interaction.interaction_type, interaction.created_at]
    )
  end

  def self.find(id)
    result = session.execute("SELECT * FROM interactions WHERE id = ?", arguments: [id]).first
    return nil unless result

    Interaction.new(
      id: result['id'],
      user_id: result['user_id'],
      post_id: result['post_id'],
      interaction_type: result['interaction_type'],
      created_at: result['created_at']
    )
  end
end