class ChatsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!
  
  def get_all_chats
    if current_devise_api_token
      render json: current_devise_api_token.resource_owner.chats
    else
      render json: { message: 'error' }, status: :unauthorized
    end
  end

  def get_all_public_chats
    public_chats = Chat.where("type = ?", 'public')
    render json: public_chats
  end
end
