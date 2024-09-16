require 'cassandra'

begin
  puts "Attempting to connect to Cassandra..."
  CASSANDRA_CLIENT = Cassandra.cluster(
    hosts: ['127.0.0.1'],
    port: 9042,
    timeout: 10  # Set a 10-second timeout
  )
  puts "Cassandra cluster object created successfully."

  puts "Attempting to connect to keyspace..."
  CASSANDRA_SESSION = CASSANDRA_CLIENT.connect('social_media_analytics')
  puts "Connected to keyspace successfully."
rescue Cassandra::Errors::NoHostsAvailable => e
  puts "Failed to connect to Cassandra: No hosts available. Error: #{e.message}"
rescue Cassandra::Errors::AuthenticationError => e
  puts "Failed to connect to Cassandra: Authentication error. Error: #{e.message}"
rescue => e
  puts "Failed to connect to Cassandra: Unexpected error. Error: #{e.message}"
end