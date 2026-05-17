module Api
  module V1
    class MortgageApplicationsController < ApplicationController

      before_action :authenticate_user!

      def index
        @applications = current_user.mortgage_applications.order(created_at: :desc)

        render json: { mortgage_applications: @applications }, status: :ok
      end

      def create
        @application = current_user.mortgage_applications.build(mortgage_params)

        if @application.save
          render json: {
            message: "Mortgage application submitted successfully.",
            application: @application
          }, status: :created
        else
          render json: { errors: @application.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def mortgage_params
        params.require(:mortgage_application).permit(
          :annual_income, :monthly_expenses, :deposit_amount, :property_value, :term_years
        )
      end
    end
  end
end
