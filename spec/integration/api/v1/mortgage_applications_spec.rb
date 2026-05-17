require 'rails_helper'

RSpec.describe "Api::V1::MortgageApplications Integration", type: :request do

  let!(:user) { User.create!(email: "integration_buyer@example.com", password: "password123", password_confirmation: "password123") }

  let(:valid_payload) do
    {
      mortgage_application: {
        annual_income: 80000,
        monthly_expenses: 1200,
        deposit_amount: 30000,
        property_value: 250000,
        term_years: 30
      }
    }
  end

  before do
    sign_in user
  end

  describe "POST /api/v1/mortgage_applications" do

    it "persists a real database row tied to the customer, default-initialized to 'new'" do

      expect {
        post "/api/v1/mortgage_applications", params: valid_payload, as: :json
      }.to change(MortgageApplication, :count).by(1)

      expect(response).to have_http_status(:created)
      
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Mortgage application submitted successfully.")
      expect(json["application"]["status"]).to eq("new")
      expect(json["application"]["user_id"]).to eq(user.id)
    end
  end

  describe "GET /api/v1/mortgage_applications" do

    it "pulls the correct multi-record historical list directly out of the database" do

      user.mortgage_applications.create!(annual_income: 60000, monthly_expenses: 1000, deposit_amount: 20000, property_value: 150000, term_years: 25, status: "new")
      user.mortgage_applications.create!(annual_income: 90000, monthly_expenses: 1100, deposit_amount: 45000, property_value: 220000, term_years: 30, status: "under_process")

      get "/api/v1/mortgage_applications", as: :json

      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body)
      expect(json["mortgage_applications"].count).to eq(2)
      expect(json["mortgage_applications"].first["status"]).to eq("under_process")
    end
  end
end
