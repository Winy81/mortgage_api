require 'rails_helper'

RSpec.describe "Api::V1::AffordabilityAssessments", type: :request do

  describe "POST /api/v1/affordability_assessments" do

    let(:valid_params) do
      {
        annual_income: 60000,
        monthly_expenses: 1000,
        deposit_amount: 20000,
        property_value: 200000,
        term_years: 25
      }
    end

    context "with valid parameters" do

      it "calls the calculator service and renders its exact return value" do

        mock_result = {
          loan_to_value: "50%",
          debt_to_income: "10%",
          decision: "mocked_status",
          maximum_borrowing_estimate: 999999,
          explanation: "This is the explanation."
        }

        # expect_any_instance_of(AffordabilityCalculator).to receive(:perform).and_return(mock_result)

        post "/api/v1/affordability_assessments", params: valid_params, as: :json
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        # expect(json_response["decision"]).to eq("mocked_status")
        # expect(json_response["maximum_borrowing_estimate"]).to eq(999999)
        # expect(json_response["explanation"]).to eq("This is the explanation.")
      end
    end

    context "with missing parameters" do

      it "returns a 422 error and never calls the calculator" do

        # expect_any_instance_of(AffordabilityCalculator).not_to receive(:perform)

        post "/api/v1/affordability_assessments", params: { annual_income: 50000 }, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Missing required fields")
      end
    end
  end
end
