class PropertyValuationResultFetcherJob < ApplicationJob
  queue_as :default

  def perform
    applications = MortgageApplication.sent
    return if applications.empty?

    applications.find_each do |app|
      app.with_lock do
        next unless app.status == 'sent'

        Rails.logger.info "MOCK API FETCH: Checking status for Application ##{app.id} | Property Value: £#{app.property_value}"

        # =========================================================================
        # LOGIC EXPLANATION FOR INTERVIEW WALKTHROUGH:
        # We then match against the API response payload:
        # 1. No Response Available -> Do nothing. Keep status as 'sent' for next cron loop.
        # 2. Response is 'declined' -> Invoke app.mark_as_likely_declined!
        # 3. Response is 'approved' -> Invoke app.mark_as_likely_approved!
        # =========================================================================

        # Mocking a variable to represent our inbound network payload status
        # Options: nil (still processing), 'approved', 'declined'
        api_response_status = nil

        if api_response_status == 'approved'
          app.mark_as_likely_approved!
          app.update!(explanation: "#{app.explanation} | Stage 3: Valuation confirmed by vendor.")
        elsif api_response_status == 'declined'
          app.mark_as_unlikely_approved!
          app.update!(explanation: "#{app.explanation} | Stage 3: Valuation rejected by vendor.")
        else
          Rails.logger.info "MOCK API STATUS: Vendor response still pending for Application ##{app.id}."
        end
      end
    end
  end
end


