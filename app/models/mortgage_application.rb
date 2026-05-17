# app/models/mortgage_application.rb
class MortgageApplication < ApplicationRecord
  belongs_to :user

  VALID_STATUSES = ['new', 'processing', 'likely_approved', 'unlikely_approved', 'approved', 'declined'].freeze

  validates :annual_income, :monthly_expenses, :deposit_amount, :property_value, :term_years, :status, presence: true
  validates :annual_income, :monthly_expenses, :deposit_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :property_value, numericality: { greater_than: 0 }
  validates :term_years, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 40 }
  validates :status, inclusion: { in: VALID_STATUSES, message: "%{value} is not a valid processing state" }

  def self.new_mortgage_applications
    where(status: 'new')
  end

  def self.under_process
    where(status: 'processing')
  end

  def self.likely_approved
    where(status: 'likely_approved')
  end

  def self.unlikely_approved
    where(status: 'unlikely_approved')
  end

  def self.approved
    where(status: 'approved')
  end

  def self.declined
    where(status: 'declined')
  end

  def mark_as_new!
    update!(status: 'new')
  end

  def mark_as_processing!
    update!(status: 'processing')
  end

  def mark_as_likely_approved!
    update!(status: 'likely_approved')
  end

  def mark_as_unlikely_approved!
    update!(status: 'unlikely_approved')
  end

  def mark_as_approved!
    update!(status: 'approved')
  end

  def mark_as_declined!
    update!(status: 'declined')
  end
end