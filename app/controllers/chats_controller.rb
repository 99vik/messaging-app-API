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

  def create_chat
    chat = Chat.new(chat_params)
    chat.admin_id = current_devise_api_token.resource_owner.id
    
    if chat.save
      chat.chat_participants.create(participant_id: current_devise_api_token.resource_owner.id)
      render json: chat
    else
      render json: chat.errors, status: :unprocessable_entity
    end
  end

  private 
  
  def chat_params
    params.require(:chat).permit(:name, :type)
  end
end
