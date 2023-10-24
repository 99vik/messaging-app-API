class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!
    
  def get_all_chat_messages
    chat = Chat.find(params[:id])
    user_id = current_devise_api_token.resource_owner.id

    if chat
        if !chat.participant_ids.include?(user_id)
          render json: { message: "User is not chat participant" }, status: :unauthorized
        else
          messages_with_users = chat.messages.map do |message|
            message_user = message.user
            user = {
              id: message_user.id,
              username: message_user.username,
              description: message_user.description,
            }
            message.as_json.merge(user: user)
          end
          render json: messages_with_users
        end
    else
      render json: { message: "Error loading chat messages" }, status: :unprocessable_entity
    end
  end

  def send_message
    chat = Chat.find(new_message_params[:chatID])
    user_id = current_devise_api_token.resource_owner.id  

    return if !chat.participant_ids.include?(user_id)  
    
    message = chat.messages.new
    message[:user_id] = user_id
    message[:body] = new_message_params[:body]

    if message.save
      render json: message
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  private

  def new_message_params
    params.require(:message).permit(:body, :chatID)
  end
end
