require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do

  describe "POST /api/v1/login" do

    let!(:user) { User.create!(email: "test@example.com", password: "password123") }

    context "with valid credentials" do

      it "returns a successful JSON message" do

        post "/api/v1/login", params: { user: { email: user.email, password: "password123" } }, as: :json
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Logged in successfully.")
        expect(json_response["user"]["email"]).to eq(user.email)
      end
    end

    context "with invalid credentials" do

      it "returns an unauthorized status code" do
        
        post "/api/v1/login", params: { user: { email: user.email, password: "wrongpassword" } }, as: :json
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid email or password.")
      end
    end
  end
end
