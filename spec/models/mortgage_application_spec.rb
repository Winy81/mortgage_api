require 'rails_helper'

RSpec.describe MortgageApplication, type: :model do
  
  let(:user) { User.create!(email: "customer@example.com", password: "password123") }
  
  let(:valid_attributes) do
    {
      user: user,
      annual_income: 60000,
      monthly_expenses: 1200,
      deposit_amount: 20000,
      property_value: 200000,
      term_years: 25
    }
  end

  describe 'Status Inclusions' do

    it "automatically initializes with a default status of 'new'" do

      application = MortgageApplication.new(valid_attributes)

      expect(application.status).to eq('new')
      expect(application).to be_valid
    end

    MortgageApplication::VALID_STATUSES.each do |valid_state|
      it "explicitly permits the state '#{valid_state}'" do
        application = MortgageApplication.new(valid_attributes.merge(status: valid_state))

        expect(application).to be_valid
      end
    end

    it "strictly rejects completely random values outside the collection boundaries" do

      application = MortgageApplication.new(valid_attributes.merge(status: "unauthorized_state"))

      expect(application).not_to be_valid
      expect(application.errors[:status]).to include("unauthorized_state is not a valid processing state")
    end
  end

  describe 'Financial Numericality Boundaries' do

    it "is valid with normal positive entries" do

      application = MortgageApplication.new(valid_attributes)

      expect(application).to be_valid
    end

    it "is invalid if financial inputs are negative values" do

      application = MortgageApplication.new(valid_attributes.merge(annual_income: -100))

      expect(application).not_to be_valid
      expect(application.errors[:annual_income]).to include("must be greater than or equal to 0")
    end

    it "is invalid if property value is exactly zero" do

      application = MortgageApplication.new(valid_attributes.merge(property_value: 0))

      expect(application).not_to be_valid
      expect(application.errors[:property_value]).to include("must be greater than 0")
    end
  end
end
