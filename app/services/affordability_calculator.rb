class AffordabilityCalculator
  
  def initialize(income:, expenses:, deposit:, property_value:, term_years:)
    @income = income.to_f
    @expenses = expenses.to_f
    @deposit = deposit.to_f
    @property_value = property_value.to_f
    @term_years = term_years.to_i
  end

  def perform
    return failure_response("Property value must be greater than zero.") if @property_value <= 0

    ltv = ((loan_amount / @property_value) * 100).round(2)
    dti = (((@expenses * 12) / @income) * 100).round(2)
    max_borrowing = (@income * 4.5).round(2)
    
    ltv_ok = ltv <= 90
    dti_ok = dti <= 45
    borrowing_ok = loan_amount <= max_borrowing
    approved = ltv_ok && dti_ok && borrowing_ok

    {
      loan_to_value: "#{ltv}%",
      debt_to_income: "#{dti}%",
      decision: approved ? "approved" : "declined",
      maximum_borrowing_estimate: max_borrowing,
      explanation: generate_explanation(ltv_ok, dti_ok, borrowing_ok, ltv, dti, max_borrowing)
    }
  end

  private

  def loan_amount
    [@property_value - @deposit, 0].max
  end

  def failure_response(message)
    { 
      decision: "declined", 
      explanation: message, 
      loan_to_value: "0%", 
      debt_to_income: "0%", 
      maximum_borrowing_estimate: 0 
    }
  end

  def generate_explanation(ltv_ok, dti_ok, borrowing_ok, ltv, dti, max_borrowing)
    return "Application meets all affordability and lending criteria." if ltv_ok && dti_ok && borrowing_ok
    
    reasons = []
    reasons << "Loan-to-Value ratio (#{ltv}%) exceeds maximum limit of 90%" unless ltv_ok
    reasons << "Debt-to-Income ratio (#{dti}%) exceeds maximum limit of 45%" unless dti_ok
    reasons << "Required loan amount (£#{(loan_amount).round(2)}) exceeds maximum borrowing capacity (£#{max_borrowing})" unless borrowing_ok
    
    "Declined due to: #{reasons.join('; ')}."
  end
end