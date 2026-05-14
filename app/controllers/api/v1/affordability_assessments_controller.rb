class Api::V1::AffordabilityAssessmentsController < ApplicationController

  def create

    required_keys = [:annual_income, :monthly_expenses, :deposit_amount, :property_value, :term_years]
    missing_keys = required_keys.select { |key| params[key].blank? }

    if missing_keys.any?
      render json: { error: "Missing required fields: #{missing_keys.join(', ')}" }, status: :unprocessable_entity
      return
    end

    assessment = nil
    # assessment = AffordabilityCalculator.new(
    #   income: params[:annual_income],
    #   expenses: params[:monthly_expenses],
    #   deposit: params[:deposit_amount],
    #   property_value: params[:property_value],
    #   term_years: params[:term_years]
    # ).call

    render json: assessment, status: :ok
  end
end