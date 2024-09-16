class CassandraRepository
  def self.session
    CASSANDRA_SESSION
  end

  def self.test_connection
    begin
      session.execute("SELECT release_version FROM system.local")
      puts "Successfully connected to Cassandra"
    rescue => e
      puts "Failed to connect to Cassandra: #{e.message}"
    end
  end


  
end