require 'rails_helper'

RSpec.describe "Api::V1::MortgageApplications", type: :request do

  let!(:user) { User.create!(email: "customer@example.com", password: "password123") }
  
  let(:valid_payload) do
    {
      mortgage_application: {
        annual_income: 65000,
        monthly_expenses: 1100,
        deposit_amount: 25000,
        property_value: 220000,
        term_years: 30
      }
    }
  end

  describe "POST /api/v1/mortgage_applications" do

    context "when authenticated" do

      before do
        sign_in user
      end

      it "creates a new persistent database row containing a default status of 'new'" do

        expect {
          post "/api/v1/mortgage_applications", params: valid_payload, as: :json
        }.to change(MortgageApplication, :count).by(1)
        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)

        expect(json["application"]["status"]).to eq("new")
        expect(json["application"]["user_id"]).to eq(user.id)
      end
    end

    context "when unauthenticated" do

      it "returns a 401 unauthorized block when no cookie context is passed" do

        post "/api/v1/mortgage_applications", params: valid_payload, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/mortgage_applications" do

    context "when authenticated" do

      before do
        sign_in user
        
        user.mortgage_applications.create!(annual_income: 40000, monthly_expenses: 800, deposit_amount: 10000, property_value: 120000, term_years: 20, status: "new")
        user.mortgage_applications.create!(annual_income: 95000, monthly_expenses: 1500, deposit_amount: 50000, property_value: 350000, term_years: 25, status: "approved")
      end

      it "lists out all records linked specifically to this customer profile" do

        get "/api/v1/mortgage_applications", as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["mortgage_applications"].count).to eq(2)
        expect(json["mortgage_applications"].first).to include("annual_income", "status")
      end
    end
  end
end
