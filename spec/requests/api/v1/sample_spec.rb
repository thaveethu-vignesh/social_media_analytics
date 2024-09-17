require 'swagger_helper'

RSpec.describe 'API V1', type: :request do
  path '/api/v1/sample' do
    get 'Retrieves a sample' do
      produces 'application/json'
      response '200', 'sample found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string }
          }
        run_test!
      end
    end
  end
end