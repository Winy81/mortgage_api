require 'rails_helper'

RSpec.describe AffordabilityCalculator do
  describe '#perform' do

    context 'when the applicant has healthy financials' do

      it 'approves the assessment' do
        calculator = described_class.new(
          income: 100000,
          expenses: 1000,
          deposit: 50000,
          property_value: 200000,
          term_years: 25
        )
        
        result = calculator.perform
        
        expect(result[:decision]).to eq('approved')
        expect(result[:loan_to_value]).to eq('75.0%')
        expect(result[:debt_to_income]).to eq('12.0%')
        expect(result[:maximum_borrowing_estimate]).to eq(450000.0)
        expect(result[:explanation]).to include('meets all affordability')
      end
    end

    context 'when the deposit is too low' do

      it 'declines the application due to high Loan-to-Value' do

        calculator = described_class.new(
          income: 80000,
          expenses: 1000,
          deposit: 5000,
          property_value: 200000,
          term_years: 25
        )
        
        result = calculator.perform
        
        expect(result[:decision]).to eq('declined')
        expect(result[:loan_to_value]).to eq('97.5%')
        expect(result[:explanation]).to include('Loan-to-Value ratio (97.5%) exceeds maximum limit of 90.0%')
      end
    end

    context 'when the monthly outgoings are too high' do

      it 'declines the application due to high Debt-to-Income' do

        calculator = described_class.new(
          income: 50000,
          expenses: 2500,
          deposit: 30000,
          property_value: 200000,
          term_years: 25
        )
        
        result = calculator.perform
        
        expect(result[:decision]).to eq('declined')
        expect(result[:debt_to_income]).to eq('60.0%')
        expect(result[:explanation]).to include('Debt-to-Income ratio (60.0%) exceeds maximum limit of 45.0%')
      end
    end

    context 'when the required loan amount is above maximum borrowing limits' do

      it 'declines the application due to leverage capacity' do

        calculator = described_class.new(
          income: 30000,
          expenses: 500,
          deposit: 20000,
          property_value: 200000,
          term_years: 25
        )
        
        result = calculator.perform
        
        expect(result[:decision]).to eq('declined')
        expect(result[:explanation]).to include('exceeds maximum borrowing capacity (£135000.0)')
      end
    end

    context 'when edge case parameters are supplied' do

      it 'handles a zero or negative property value gracefully without crashing' do
        
        calculator = described_class.new(
          income: 50000,
          expenses: 500,
          deposit: 10000,
          property_value: 0,
          term_years: 25
        )
        
        result = calculator.perform
        
        expect(result[:decision]).to eq('declined')
        expect(result[:explanation]).to eq('Property value must be greater than zero.')
      end
    end
  end
end
