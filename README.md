# README

before starting rails server , Run mysql ,  Redis , kafka , zookeeper , sidekiq

User Analytics:

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
