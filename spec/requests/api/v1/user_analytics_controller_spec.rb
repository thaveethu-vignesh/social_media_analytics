require 'rails_helper'

RSpec.describe Api::V1::UserAnalyticsController, type: :controller do
  describe 'GET #activity_summary' do
    let(:user_id) { '123' }
    let(:summary_data) { { posts: 10, likes: 20, comments: 5 } }

    before do
      allow(AnalyticsService).to receive(:user_activity_summary).with(user_id).and_return(summary_data)
    end

    it 'returns http success' do
      get :activity_summary, params: { id: user_id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct activity summary' do
      get :activity_summary, params: { id: user_id }
      expect(JSON.parse(response.body)).to eq(summary_data.as_json)
    end

    it 'calls AnalyticsService with the correct user id' do
      expect(AnalyticsService).to receive(:user_activity_summary).with(user_id)
      get :activity_summary, params: { id: user_id }
    end
  end

  describe 'GET #top_influencers' do
    let(:influencers_data) do
      [
        { id: '1', name: 'Alice', influence_score: 95 },
        { id: '2', name: 'Bob', influence_score: 85 }
      ]
    end

    before do
      allow(UserInfluenceService).to receive(:get_top_influencers).and_return(influencers_data)
    end

    it 'returns http success' do
      get :top_influencers
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct top influencers data' do
      get :top_influencers
      expect(JSON.parse(response.body)).to eq(influencers_data.as_json)
    end

    it 'calls UserInfluenceService to get top influencers' do
      expect(UserInfluenceService).to receive(:get_top_influencers)
      get :top_influencers
    end
  end
end