class ProfileController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!

  def current_user_profile
    user = current_devise_api_token.resource_owner
    image = user.image.attached? ? url_for(user.image) : nil

    render json: { email: user.email, username: user.username, description: user.description, image: image }
  end

  def change_username
    user = current_devise_api_token.resource_owner

    if user.update(username_params)
      render json: { message: 'Username updated' }, status: :ok 
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def change_description
    user = current_devise_api_token.resource_owner

    if user.update(description_params)
      render json: { message: 'Description updated' }, status: :ok 
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def change_profile_image
    user = current_devise_api_token.resource_owner
    image = image_params[:image]

    if user.image.attach(image)
      render json: { message: 'Profile picture changed' }, status: :ok 
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def search_profiles
    user = current_devise_api_token.resource_owner
    return if !user

    query = params[:query]
    users = User.where('lower(username) LIKE ?', "%#{query.downcase}%").where.not(id: user.id)

    render json: users, only: [:id, :username, :description]
  end

  private

  def username_params
    params.require(:profile).permit(:username)
  end

  def description_params
    params.require(:profile).permit(:description)
  end

  def image_params
    params.require(:profile).permit(:image)
  end
end
