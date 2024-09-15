class CassandraRepository
  def self.session
    CASSANDRA_SESSION
  end
end