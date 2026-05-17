class PropertyValuationRequestJob < ApplicationJob
  
  queue_as :default

  def perform

    applications = MortgageApplication.under_process
    return if applications.empty?

    applications.find_each do |app|

      Rails.logger.info "MOCK API DISPATCH: Sending valuation request for Application ID: #{app.id}"

      app.mark_as_sent!
      app.update!(
        explanation: "#{app.explanation} | Stage 2: Outbound property valuation request dispatched."
      )
    end
  end
end
