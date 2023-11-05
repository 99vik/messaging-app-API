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
          messages_with_users = chat.messages.sort_by {|message| message.created_at }.map do |message|
            message_user = message.user
            user = {
              id: message_user.id,
              username: message_user.username,
              description: message_user.description,
              image: message_user.image.attached? ? url_for(message_user.image) : nil
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
      user = current_devise_api_token.resource_owner
      user_data = {
        id: user.id,
        username: user.username,
        description: user.description,
        image: user.image.attached? ? url_for(user.image) : nil
      }
      ChatChannel.broadcast_to(chat, message.as_json.merge(user: user_data))
      chat.participant_ids.each do |id|
        ActionCable.server.broadcast("user_#{id}", 'refresh')
      end
      
      render json: {message: 'Message sent'}, status: :ok
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  private

  def new_message_params
    params.require(:message).permit(:body, :chatID)
  end
end
