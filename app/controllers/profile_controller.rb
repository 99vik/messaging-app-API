class ProfileController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!

  def current_user_profile
    user = current_devise_api_token.resource_owner

    render json: { email: user.email, username: user.username, description: user.description }
  end

  def change_username
    user = current_devise_api_token.resource_owner

    if user.update(username_params)
      render json: { message: 'Username updated' }, status: :ok 
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  
  end

  private

  def username_params
    params.require(:profile).permit(:username)
  end

  
end
