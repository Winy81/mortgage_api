class MortgageApplication < ApplicationRecord
  
  belongs_to :user

  VALID_STATUSES = ['new', 'likely_approved', 'approved', 'unlikely_approved', 'declined'].freeze

  validates :annual_income, :monthly_expenses, :deposit_amount, :property_value, :term_years, :status, presence: true
  
  validates :annual_income, :monthly_expenses, :deposit_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :property_value, numericality: { greater_than: 0 }
  validates :term_years, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 40 }
  
  validates :status, inclusion: { in: VALID_STATUSES, message: "%{value} is not a valid processing state" }
end