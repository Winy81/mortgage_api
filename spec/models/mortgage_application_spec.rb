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

  describe 'Class Methods (Getters)' do

    let!(:new_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'new')) }
    let!(:under_process_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'under_process')) }
    let!(:sent_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'sent')) }
    let!(:likely_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'likely_approved')) }
    let!(:unlikely_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'unlikely_approved')) }
    let!(:approved_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'approved')) }
    let!(:declined_app) { user.mortgage_applications.create!(valid_attributes.merge(status: 'declined')) }

    describe '.new_mortgage_applications' do

      it "returns only 'new' records" do

        results = MortgageApplication.new_mortgage_applications

        expect(results).to include(new_app)
        expect(results).not_to include(under_process_app, likely_app, approved_app)
      end
    end

    describe '.under_process' do

      it "returns only 'under_process' records" do

        results = MortgageApplication.under_process

        expect(results).to include(under_process_app)
        expect(results).not_to include(new_app, sent_app, likely_app, approved_app)
      end
    end

    describe '.sent' do

      it "returns only 'sent' records" do

        results = MortgageApplication.sent

        expect(results).to include(sent_app)
        expect(results).not_to include(new_app, under_process_app, approved_app)
      end
    end

    describe '.likely_approved' do

      it "returns only 'likely_approved' records" do

        results = MortgageApplication.likely_approved

        expect(results).to include(likely_app)
        expect(results).not_to include(new_app, under_process_app, approved_app)
      end
    end

    describe '.unlikely_approved' do

      it "returns only 'unlikely_approved' records" do

        results = MortgageApplication.unlikely_approved

        expect(results).to include(unlikely_app)
        expect(results).not_to include(new_app, approved_app, declined_app)
      end
    end

    describe '.approved' do

      it "returns only 'approved' records" do

        results = MortgageApplication.approved

        expect(results).to include(approved_app)
        expect(results).not_to include(new_app, likely_app, declined_app)
      end
    end

    describe '.declined' do

      it "returns only 'declined' records" do

        results = MortgageApplication.declined

        expect(results).to include(declined_app)
        expect(results).not_to include(new_app, likely_app, approved_app)
      end
    end
  end

  describe 'Instance Methods (Setters)' do

    let(:application) { user.mortgage_applications.create!(valid_attributes.merge(status: 'approved')) }

    describe '#mark_as_new!' do

      it "updates status to 'new'" do

        application.mark_as_new!

        expect(application.reload.status).to eq('new')
      end
    end

    describe '#mark_as_under_process!' do

      it "updates status to 'under_process'" do

        application.mark_as_under_process!

        expect(application.reload.status).to eq('under_process')
      end
    end

    describe '#mark_as_sent!' do

      it "updates status to 'sent'" do

        application.mark_as_sent!

        expect(application.reload.status).to eq('sent')
      end
    end

    describe '#mark_as_likely_approved!' do

      it "updates status to 'likely_approved'" do

        application.mark_as_likely_approved!

        expect(application.reload.status).to eq('likely_approved')
      end
    end

    describe '#mark_as_unlikely_approved!' do

      it "updates status to 'unlikely_approved'" do

        application.mark_as_unlikely_approved!

        expect(application.reload.status).to eq('unlikely_approved')
      end
    end

    describe '#mark_as_approved!' do

      it "updates status to 'approved'" do

        application.mark_as_approved!

        expect(application.reload.status).to eq('approved')
      end
    end

    describe '#mark_as_declined!' do

      it "updates status to 'declined'" do

        application.mark_as_declined!

        expect(application.reload.status).to eq('declined')
      end
    end
  end
end
