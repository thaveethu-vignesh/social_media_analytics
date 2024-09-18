# README

# Social Media Analytics Platform

## Overview

This Social Media Analytics Sample app is a Ruby on Rails application . It uses Cassandra for storing large volumes of data, Redis for caching and real-time analytics, and Kafka for real-time data streaming.

## Architecture

```
[User] --> [social_media_analytics Application]
              |
              |--> [Cassandra] (Data Storage)
              |
              |--> [Redis] (Caching & Real-time Analytics)
              |
              |--> [Kafka] (Data Streaming)
              |
              |--> [Sidekiq] (Background Jobs)
```

- **Rails Application**: Handles HTTP requests, processes data, and serves API endpoints.
- **Cassandra**: Stores posts, interactions, and other large-scale data.
- **Redis**: Caches frequently accessed data and stores real-time analytics.
- **Kafka**: Streams real-time data for processing.
- **Sidekiq**: Manages background jobs for data processing and analytics calculations.

## Prerequisites

- Ruby 2.6.9
- Rails 6.1.7
- Cassandra 4.0+
- Redis 6.0+
- Kafka 2.8+
- Node.js 14+ (for webpacker)
- Yarn 1.22+

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/thaveethu-vignesh/social-media-analytics.git
   cd social-media-analytics
   ```

2. Install dependencies:
   ```
   bundle install
   yarn install
   ```

3. Set up Cassandra:
   - Start Cassandra service
   - Create keyspace and tables:
     ```
     cqlsh -f db/cassandra/schema.cql
     ```

4. Set up Redis:
   - Start Redis service

5. Set up Kafka:
   - Start Zookeeper service
   - Start Kafka service
   - Create necessary topics:
     ```
     kafka-topics.sh --create --topic posts --bootstrap-server localhost:9092
     kafka-topics.sh --create --topic interactions --bootstrap-server localhost:9092
     ```
6. Set up the database:
   ```
   rails db:create db:migrate
   ```

7. Run the Cassandra setup rake task:
   ```
   rails cassandra:setup
   ```

## Running the Application

1. Start the Rails server:
   ```
   rails server
   ```

2. Start Sidekiq for background jobs:
   ```
   bundle exec sidekiq
   ```

3. Start the Kafka consumers:
   ```
   rails kafka:start_consumers
   ```


## Data Generation

To generate test data:

```
rails data:generate
```


## API doc : 

GET /api/v1/user_analytics/top_influencers

GET /api/v1/user_analytics/:id/activity_summary


 Post Analytics:

GET /api/v1/post_analytics/:id/engagement

Platform Analytics:

GET /api/v1/platform_analytics/overall_stats

GET /api/v1/platform_analytics/post_trends

GET /api/v1/platform_analytics/interaction_trends


Real-time Analytics:

GET /api/v1/real_time_analytics/trending_topics

GET /api/v1/real_time_analytics/popular_posts


Data Generation:

POST /api/v1/generate_data
