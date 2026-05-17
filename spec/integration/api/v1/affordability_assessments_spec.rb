require 'rails_helper'

RSpec.describe "Api::V1::AffordabilityAssessments Integration", type: :request do

  describe "POST /api/v1/affordability_assessments" do

    context "with a strong financial profile" do

      it "returns a real calculated approval verdict and correct financial ratios" do

        healthy_payload = {
          annual_income: 100000,
          monthly_expenses: 1000,
          deposit_amount: 50000,
          property_value: 200000,
          term_years: 25
        }

        post "/api/v1/affordability_assessments", params: healthy_payload, as: :json

        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json["decision"]).to eq("approved")
        expect(json["loan_to_value"]).to eq("75.0%")
        expect(json["debt_to_income"]).to eq("12.0%")
        expect(json["maximum_borrowing_estimate"]).to eq(450000.0)
        expect(json["explanation"]).to include("meets all affordability")
      end
    end

    context "with a high-risk financial profile" do

      it "returns a real declined verdict pointing directly to the broken threshold metric" do
        
        risky_payload = {
          annual_income: 50000,
          monthly_expenses: 2500, # 30k annual expenses / 50k income = 60% DTI (Limit: 45.0%)
          deposit_amount: 30000,
          property_value: 200000,
          term_years: 25
        }

        post "/api/v1/affordability_assessments", params: risky_payload, as: :json

        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json["decision"]).to eq("declined")
        expect(json["explanation"]).to include("Debt-to-Income ratio (60.0%) exceeds maximum limit of 45.0%")
      end
    end
  end
end
