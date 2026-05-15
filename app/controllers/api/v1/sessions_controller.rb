module Api
  module V1
    class SessionsController < ApplicationController

      def create
        user_params = params.require(:user).permit(:email, :password)
        user = User.find_by(email: user_params[:email])

        if user&.valid_password?(user_params[:password])
          sign_in(:user, user) 

          render json: {
            message: 'Logged in successfully.',
            user: { id: user.id, email: user.email }
          }, status: :ok
        else
          render json: { error: 'Invalid email or password.' }, status: :unauthorized
        end
      rescue ActionController::ParameterMissing
        render json: { error: 'Missing required user parameters.' }, status: :unprocessable_entity
      end

      def destroy
        sign_out(:user)
        render json: { message: 'Logged out successfully.' }, status: :ok
      end
    end
  end
end
