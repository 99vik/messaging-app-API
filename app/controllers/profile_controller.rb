class ProfileController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!

  def current_user_profile
    user = current_devise_api_token.resource_owner

    render json: { email: user.email, username: user.username, description: user.description }
  end
end
