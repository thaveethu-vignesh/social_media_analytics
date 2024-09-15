require 'cassandra'

CASSANDRA_CLIENT = Cassandra.cluster(
  hosts: ['127.0.0.1'],
  port: 9042
)

CASSANDRA_SESSION = CASSANDRA_CLIENT.connect('social_media_analytics')