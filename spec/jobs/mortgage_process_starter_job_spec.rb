require 'rails_helper'

RSpec.describe MortgageProcessStarterJob, type: :job do
  let(:user) { User.create!(email: "underwriter_worker@example.com", password: "password123") }

  let(:base_attributes) do
    {
      user: user,
      annual_income: 100000,
      monthly_expenses: 1000,
      deposit_amount: 50000,
      property_value: 200000,
      term_years: 25,
      status: 'new'
    }
  end

  describe '#perform' do

    context 'when processing a healthy new application' do

      it "transitions the status from 'new' to 'under_process' upon passing affordability" do

        passing_application = MortgageApplication.create!(base_attributes)

        described_class.new.perform

        passing_application.reload

        expect(passing_application.status).to eq('under_process')
        expect(passing_application.loan_to_value).to eq('75.0%')
        expect(passing_application.debt_to_income).to eq('12.0%')
        expect(passing_application.explanation).to include('meets all affordability and lending criteria')
      end
    end

    context 'when processing an unhealthy new application' do

      it "transitions the status from 'new' directly to 'declined' upon failing affordability" do

        failing_application = MortgageApplication.create!(
          base_attributes.merge(deposit_amount: 5000)
        )

        described_class.new.perform

        failing_application.reload

        expect(failing_application.status).to eq('declined')
        expect(failing_application.loan_to_value).to eq('97.5%')
        expect(failing_application.explanation).to include('exceeds maximum limit of 90.0%')
      end
    end

    context 'when no new applications exist inside the database' do

      it 'exits early without performing calculations or throwing errors' do

        processed_application = MortgageApplication.create!(
          base_attributes.merge(status: 'under_process')
        )

        expect(AffordabilityCalculator).not_to receive(:new)

        expect { described_class.new.perform }.not_to raise_error
        expect(processed_application.reload.status).to eq('under_process')
      end
    end
  end
end
