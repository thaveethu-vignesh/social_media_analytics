# lib/tasks/cassandra_test.rake

namespace :cassandra do
  desc "Test Cassandra connection and operations"
  task test: :environment do
    puts "Rails.env: #{Rails.env}"
    puts "ENV['RAILS_ENV']: #{ENV['RAILS_ENV']}"

    puts "\nTesting Cassandra connection..."
    begin
      # Test connection
      result = CASSANDRA_SESSION.execute("SELECT release_version FROM system.local")
      puts "Successfully connected to Cassandra. Version: #{result.first['release_version']}"

      # Test basic operations
      puts "\nTesting basic Cassandra operations..."
      
      # Create a test keyspace if it doesn't exist
      CASSANDRA_SESSION.execute("CREATE KEYSPACE IF NOT EXISTS test_keyspace WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")
      
      # Use the test keyspace
      CASSANDRA_SESSION.execute("USE test_keyspace")
      
      # Create a test table
      CASSANDRA_SESSION.execute("CREATE TABLE IF NOT EXISTS test_table (id UUID PRIMARY KEY, name TEXT)")
      
      # Insert a record
      id = Cassandra::Uuid::Generator.new.uuid
      CASSANDRA_SESSION.execute("INSERT INTO test_table (id, name) VALUES (?, ?)", arguments: [id, "Test Name"])
      
      # Retrieve the record
      result = CASSANDRA_SESSION.execute("SELECT * FROM test_table WHERE id = ?", arguments: [id])
      puts "Retrieved test record: #{result.first}"
      
      # Clean up
      CASSANDRA_SESSION.execute("DROP TABLE test_table")
      CASSANDRA_SESSION.execute("DROP KEYSPACE test_keyspace")
      
      puts "Cassandra operations completed successfully."
    rescue => e
      puts "Error during Cassandra operations: #{e.class.name} - #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end