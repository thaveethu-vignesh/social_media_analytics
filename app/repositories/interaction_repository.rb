require 'securerandom'



class InteractionRepository < CassandraRepository
  def self.save(interaction)

    # Generate a random 64-bit integer (bigint)
    random_bigint = SecureRandom.random_number(2**63 - 1)

    # Create Cassandra::Types::Bigint objects
    interaction_bigint = Cassandra::Types::Bigint.new(random_bigint)


    session.execute(
      "INSERT INTO interactions_by_user (user_id, interaction_id, post_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?)",
      arguments: [interaction.user_id, interaction_bigint, interaction.post_id, interaction.interaction_type, interaction.created_at]
    )
    session.execute(
      "INSERT INTO interactions_by_post (post_id, interaction_id, user_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?)",
      arguments: [interaction.post_id, interaction_bigint, interaction.user_id, interaction.interaction_type, interaction.created_at]
    )
    increment_counter("platform_stats", "total_interactions", 1)
    increment_user_activity(interaction.user_id, interaction.created_at, :interaction)


    year = interaction.created_at.year
    month = interaction.created_at.month

    year_bigint = Cassandra::Types::Bigint.new(year)

    month_bigint = Cassandra::Types::Bigint.new(month)

 


    #interaction_bigint = Cassandra::Types::Bigint.new(interaction.id)

    user_id_bigint = Cassandra::Types::Bigint.new(interaction.user_id)

    post_id_bigint = Cassandra::Types::Bigint.new(interaction.post_id)

    session.execute(
      "INSERT INTO interactions_by_time (year, month, interaction_id, user_id, post_id, interaction_type, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
      arguments: [year_bigint, month_bigint, interaction_bigint, user_id_bigint, post_id_bigint, interaction.interaction_type, interaction.created_at]
    )


  end

  def self.interactions_by_post(post_id, limit = 100)
    puts "Entering interactions_by_post method"
    puts "Original post_id: #{post_id} (#{post_id.class})"
    
    # Convert to Cassandra bigint
    post_id_bigint = Cassandra::Types::Bigint.new(post_id)
    
    puts "post_id as Cassandra::Types::Bigint: #{post_id_bigint}"
    
    begin
      statement = session.prepare("SELECT * FROM interactions_by_post WHERE post_id = ? LIMIT ?")
      results = session.execute(statement, arguments: [post_id_bigint, limit])
      return results.map do |row|
        {
          id: row['interaction_id'],
          user_id: row['user_id'],
          post_id: row['post_id'],
          interaction_type: row['interaction_type'],
          created_at: row['created_at']
        }
      end
    rescue => e
      puts "Query execution failed: #{e.message}"
      puts "Error class: #{e.class}"
      raise
    end
  end


def self.interactions_by_user(user_id, limit = 10)
  puts "Entering posts_by_user method"
  puts "Original user_id: #{user_id} (#{user_id.class})"
  
  # Convert to Cassandra bigint
  user_id_bigint = Cassandra::Types::Bigint.new(user_id)
  
  puts "interactions_by_user as Cassandra::Types::Bigint: #{user_id_bigint}"
  
  begin
    statement = session.prepare("SELECT * FROM interactions_by_user WHERE user_id = ? LIMIT ?")
    results = session.execute(statement, arguments: [user_id_bigint, limit])
    return results.map { |row| build_interaction(row) }
  rescue => e
    puts "Query execution failed: #{e.message}"
    puts "Error class: #{e.class}"
    raise
  end
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

  def self.increment_counter(table, column, value = 1, timestamp = Time.now)
    # Group the timestamp by the day (truncate time to the start of the day)
    day_timestamp = timestamp.beginning_of_day

    # Generate the query to increment the counter
    query = "UPDATE #{table} SET #{column} = #{column} + ? WHERE stat_timestamp = ?"
    arguments = [value, day_timestamp]

    begin
      # Execute the query
      session.execute(query, arguments: arguments)
      true
    rescue Cassandra::Errors::InvalidError => e
      Rails.logger.error "Failed to increment counter: #{e.message}"
      false
    end
  end

  def self.increment_user_activity(user_id, timestamp, activity_type)
    hour = timestamp.beginning_of_hour
    column = activity_type == :post ? 'post_count' : 'interaction_count'
    session.execute(
      "UPDATE user_activity_by_hour SET #{column} = #{column} + 1 WHERE user_id = ? AND activity_hour = ?",
      arguments: [user_id, hour]
    )
  end


  def self.interactions_since(start_time)
    year = start_time.year
    month = start_time.month

    results = session.execute(
      "SELECT * FROM interactions_by_time WHERE year = ? AND month = ? AND created_at >= ?",
      arguments: [year, month, start_time]
    )

    results.map do |row|
      Interaction.new(
        id: row['interaction_id'],
        user_id: row['user_id'],
        post_id: row['post_id'],
        interaction_type: row['interaction_type'],
        created_at: row['created_at']
      )
    end
  end


end