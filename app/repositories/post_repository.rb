require 'date'
require 'cassandra'


class PostRepository < CassandraRepository
  def self.save(post)
    session.execute(
      "INSERT INTO posts_by_user (user_id, post_id, content, created_at) VALUES (?, ?, ?, ?)",
      arguments: [post.user_id, post.id, post.content, post.created_at]
    )
    increment_counter("platform_stats", "total_posts", 1)
    increment_user_activity(post.user_id, post.created_at, :post)

    # Save to the time-series table posts_by_time
    year = post.created_at.year.to_i
    month = post.created_at.month.to_i

    year_bigint = Cassandra::Types::Bigint.new(year)

    month_bigint = Cassandra::Types::Bigint.new(month)


    post_id = Integer(post.id)  
    user_id = Integer(post.user_id)  


    user_id_bigint = Cassandra::Types::Bigint.new(post.user_id)

    post_id_bigint = Cassandra::Types::Bigint.new(post.id)

    session.execute(
      "INSERT INTO test_sample (year, month, post_id, user_id, content) VALUES (?, ?, ?, ?, ?)",
      arguments: [year_bigint, month_bigint, post_id_bigint, user_id_bigint, post.content]
    )


    puts "Sample insert done , going to actual insert #{post.inspect} "

    Rails.logger.info("Inserting post: #{post.inspect}")

    post_id = post.id.to_i  # Ensure post_id is an integer
    user_id = post.user_id.to_i  # Ensure user_id is an integer
    year = post.created_at.year.to_i
    month = post.created_at.month.to_i
    created_at = post.created_at.to_time  # Ensure this is a valid timestamp

    puts "Prepared values: year=#{year}, month=#{month}, post_id=#{post_id}, user_id=#{user_id}, created_at=#{created_at}"

    # Save to the original posts table

    session.execute(
      "INSERT INTO posts_by_time (year, month, post_id, user_id, content, created_at) VALUES (?, ?, ?, ?, ?, ?)",
      arguments: [year_bigint, month_bigint, post_id_bigint, user_id_bigint, post.content, post.created_at]
    )


  end

  def self.find(user_id, post_id)
    result = session.execute(
      "SELECT * FROM posts_by_user WHERE user_id = ? AND post_id = ?",
      arguments: [user_id.to_i, post_id]
    ).first
    build_post(result) if result
  end

  def self.diagnose_cassandra_types
  puts "Diagnosing Cassandra types..."
  
  test_id = 716
  puts "Test ID: #{test_id} (#{test_id.class})"
  
  # Try different type conversions
  as_integer = test_id.to_i
  as_string = test_id.to_s
  as_bigdecimal = BigDecimal(test_id.to_s)
  
  puts "As Integer: #{as_integer} (#{as_integer.class})"
  puts "As String: #{as_string} (#{as_string.class})"
  puts "As BigDecimal: #{as_bigdecimal} (#{as_bigdecimal.class})"
  
  # Try to get column information
  begin
    metadata = session.cluster.metadata
    keyspace = metadata.keyspace('social_media_analytics')
    table = keyspace.table('posts_by_user')
    user_id_column = table.column('user_id')
    puts "user_id column type: #{user_id_column.type}"
  rescue => e
    puts "Error getting column information: #{e.message}"
  end
  
  # Try a simple select
  begin
    result = session.execute("SELECT user_id FROM posts_by_user LIMIT 1")
    row = result.first
    if row
      puts "Sample user_id from database: #{row['user_id']} (#{row['user_id'].class})"
    else
      puts "No rows found in posts_by_user table"
    end
  rescue => e
    puts "Error executing select: #{e.message}"
  end
end


def self.posts_by_user(user_id, limit = 10)
  puts "Entering posts_by_user method"
  puts "Original user_id: #{user_id} (#{user_id.class})"
  
  # Convert to Cassandra bigint
  user_id_bigint = Cassandra::Types::Bigint.new(user_id)
  
  puts "user_id as Cassandra::Types::Bigint: #{user_id_bigint}"
  
  begin
    statement = session.prepare("SELECT * FROM posts_by_user WHERE user_id = ? LIMIT ?")
    results = session.execute(statement, arguments: [user_id_bigint, limit])
    return results.map { |row| build_post(row) }
  rescue => e
    puts "Query execution failed: #{e.message}"
    puts "Error class: #{e.class}"
    raise
  end
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



  def self.posts_since(start_time)
    year = start_time.year
    month = start_time.month

    results = session.execute(
      "SELECT * FROM posts_by_time WHERE year = ? AND month = ? AND created_at >= ?",
      arguments: [year, month, start_time]
    )
    
    results.map do |row|
      Post.new(
        id: row['post_id'],
        user_id: row['user_id'],
        content: row['content'],
        created_at: row['created_at']
      )
    end
  end


end