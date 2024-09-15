namespace :cassandra do
  desc "Set up Cassandra keyspace and tables"
  task setup: :environment do
    cluster = Cassandra.cluster(hosts: ['127.0.0.1'])
    session = cluster.connect

    # Create keyspace
    session.execute("CREATE KEYSPACE IF NOT EXISTS social_media_analytics WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")

    session.execute("USE social_media_analytics")

    # Create posts table
    session.execute("CREATE TABLE IF NOT EXISTS posts (
      id UUID PRIMARY KEY,
      user_id UUID,
      content TEXT,
      created_at TIMESTAMP
    )")

    # Create interactions table
    session.execute("CREATE TABLE IF NOT EXISTS interactions (
      id UUID PRIMARY KEY,
      user_id UUID,
      post_id UUID,
      interaction_type TEXT,
      created_at TIMESTAMP
    )")

    puts "Cassandra keyspace and tables created successfully."
  end
end