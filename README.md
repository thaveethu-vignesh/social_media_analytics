# README

# Social Media Analytics Platform

## Overview

This Social Media Analytics Sample app is a Ruby on Rails application . It uses Cassandra for storing large volumes of data, Redis for caching and real-time analytics, and Kafka for real-time data streaming.


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






# Project Architecture

<img width="730" alt="Screenshot 2024-09-19 at 2 43 03 PM" src="https://github.com/user-attachments/assets/ee8155ae-a761-4d10-998a-4326757dfb72">


## Overview
This project is built using Ruby on Rails to demonstrate various concepts and technologies commonly used in large-scale social media analytics systems. The architecture is designed to handle data generation, storage, real-time processing, and analytics computation.

## Key Components

### 1. Ruby on Rails Application
- Core of the project, handling business logic and API endpoints
- Integrates with various data stores and services

### 2. Data Generator Service
- Simulates user activities (posts, interactions) asynchronously using Sidekiq
- Publishes data to MySQL, Cassandra, and Kafka

### 3. Storage
- MySQL: Used for learning and basic data storage
- Cassandra: Primary storage for scalability, with multiple tables optimized for different query patterns

### 4. Kafka
- Enables real-time data streaming for analytics
- Producers: Data Generator Service
- Consumers: Process streams for real-time analytics

### 5. Redis
- Stores computed analytics data (e.g., popular posts, trending topics) using ZSET structure
- Caching layer for improved performance
- Supports Sidekiq for background job processing

### 6. Sidekiq
- Manages asynchronous tasks, including data generation and influencer computation

### 7. API Layer
- Exposes endpoints for frontend to access various data and analytics

## Data Flow

1. Data Generation:
   - Sidekiq tasks simulate user activities
   - Generated data is stored in MySQL and Cassandra
   - Events are published to Kafka

2. Real-time Processing:
   - Kafka consumers process incoming data streams
   - Compute analytics like popular posts, trending topics, and influencer data
   - Store results in Redis using appropriate data structures (e.g., ZSET)

3. Batch Processing:
   - Separate Sidekiq task computes influencer data periodically

4. Data Access:
   - API endpoints retrieve data from various sources (MySQL, Cassandra, Redis)
   - Serve processed analytics and raw data to the frontend

## Scalability Considerations

- Cassandra: Distributed nature allows for horizontal scaling of data storage
- Kafka: Enables parallel processing of real-time data streams
- Redis: Provides fast access to computed analytics and serves as a caching layer
- Sidekiq: Allows for distributed and scalable background job processing




