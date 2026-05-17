class MortgageProcessStarterJob < ApplicationJob
  
  queue_as :default

  def perform
    applications = MortgageApplication.new_mortgage_applications
    return if applications.empty?

    applications.find_each do |app|

      app.with_lock do

        next unless app.new?

        result = AffordabilityCalculator.new(
          income: app.annual_income,
          expenses: app.monthly_expenses,
          deposit: app.deposit_amount,
          property_value: app.property_value,
          term_years: app.term_years
        ).perform

        app.update!(
          loan_to_value: result[:loan_to_value],
          debt_to_income: result[:debt_to_income],
          maximum_borrowing_estimate: result[:maximum_borrowing_estimate],
          explanation: result[:explanation]
        )

        if result[:decision] == 'approved'
          app.mark_as_under_process!
        else
          app.mark_as_declined!
        end
      end
    end
  end
end

