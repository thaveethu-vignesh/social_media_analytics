# lib/tasks/cassandra_setup.rake

namespace :cassandra do
  desc "Set up Cassandra keyspace and tables"
  task setup: :environment do
    cluster = Cassandra.cluster(hosts: ['127.0.0.1'])
    session = cluster.connect

    keyspace = 'social_media_analytics'

    puts "Setting up Cassandra keyspace and tables..."

    # Create keyspace
    session.execute("CREATE KEYSPACE IF NOT EXISTS #{keyspace} WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")
    session.execute("USE #{keyspace}")

    # Drop existing tables
    existing_tables = ['posts_by_user', 'interactions_by_user','interactions_by_post','user_activity_by_hour','platform_stats']
    existing_tables.each do |table|
      session.execute("DROP TABLE IF EXISTS #{table}")
    end

    # Create new tables
    create_table_queries = [
      "CREATE TABLE posts_by_user (
        user_id bigint,
        post_id bigint,
        content text,
        created_at timestamp,
        PRIMARY KEY ((user_id), post_id)
      ) WITH CLUSTERING ORDER BY (post_id DESC)",

      "CREATE TABLE interactions_by_user (
        user_id bigint,
        interaction_id bigint,
        post_id bigint,
        interaction_type text,
        created_at timestamp,
        PRIMARY KEY ((user_id), interaction_id)
      ) WITH CLUSTERING ORDER BY (interaction_id DESC)",

      "CREATE TABLE interactions_by_post (
        post_id bigint,
        interaction_id bigint,
        user_id bigint,
        interaction_type text,
        created_at timestamp,
        PRIMARY KEY ((post_id), interaction_id)
      ) WITH CLUSTERING ORDER BY (interaction_id DESC)",

      "CREATE TABLE user_activity_by_hour (
        user_id bigint,
        activity_hour timestamp,
        post_count counter,
        interaction_count counter,
        PRIMARY KEY ((user_id), activity_hour)
      ) WITH CLUSTERING ORDER BY (activity_hour DESC)",

      "CREATE TABLE platform_stats (
        stat_date date,
        total_users counter,
        total_posts counter,
        total_interactions counter,
        PRIMARY KEY (stat_date)
      )"
    ]

    create_table_queries.each do |query|
      session.execute(query)
    end

    puts "Cassandra keyspace and tables created successfully."
  rescue => e
    puts "Error setting up Cassandra: #{e.message}"
    puts e.backtrace.join("\n")
  ensure
    cluster.close if cluster
  end
end