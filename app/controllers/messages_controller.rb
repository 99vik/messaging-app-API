class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!
    
  def get_all_chat_messages
    chat = Chat.find(params[:id])
    user_id = current_devise_api_token.resource_owner.id

    if chat
        if !chat.participant_ids.include?(user_id)
          render json: { message: "Uses is not chat participant" }, status: :unauthorized
        else
          render json: chat.messages
        end
    else
      render json: { message: "Error loading chat messages" }, status: :unprocessable_entity
    end


  end
end
