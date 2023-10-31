class ChatsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!
  
  def get_all_chats
    if current_devise_api_token
      chats = current_devise_api_token.resource_owner.chats

      chats_expanded = chats.map do |chat|
        last_message = chat.messages.last
        if last_message
          last_message_time = last_message.created_at
        else
          last_message_time = chat.created_at
        end
        
        if chat[:type] == 'direct'
          other_user = User.find(chat.participant_ids.find { |id| id != current_devise_api_token.resource_owner.id })
          image = other_user.image.attached? ? url_for(other_user.image) : nil
          chat.as_json.merge(last_message: last_message, name: other_user.username, image: image, last_message_time: last_message_time.to_i)
        else
          image = chat.image.attached? ? url_for(chat.image) : nil
          chat.as_json.merge(last_message: last_message, image: image, last_message_time: last_message_time.to_i)
        end
      end

      render json: chats_expanded.sort_by { |chat| chat[:last_message_time] }.reverse
    else
      render json: { message: 'error' }, status: :unauthorized
    end
  end

  def get_chat_participants
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(params[:id])
    return if !chat.participant_ids.include?(current_user.id) || chat.type == 'direct'

    participants = chat.participants
    participants_with_images = participants.map do |participant|
      next if participant.id == current_user.id

      image = participant.image.attached? ? url_for(participant.image) : nil
      participant.as_json.merge(image: image)
    end

    render json: participants_with_images.compact()
  end

  def get_all_public_chats
    public_chats = Chat.where("type = ?", 'public')
    render json: public_chats
  end

  def create_chat
    chat = Chat.new(chat_params)
    chat.admin_id = current_devise_api_token.resource_owner.id
    
    if chat.save
      user = current_devise_api_token.resource_owner
      chat.chat_participants.create(participant_id: user.id)
      UserChatsChannel.broadcast_to(user, 'added chat' )
      render json: chat
    else
      render json: chat.errors, status: :unprocessable_entity
    end
  end

  def join_public_chat
    chat = Chat.find(params[:id])
    user = current_devise_api_token.resource_owner

    return if chat.type != 'public'

    if !chat.participant_ids.include?(user.id)
      chat.chat_participants.create(participant_id: user.id)
      UserChatsChannel.broadcast_to(user, {id: chat.id} )

      render json: chat, status: :ok
    else
      render json: { message: "Error adding to chat" }, status: :unprocessable_entity
    end
  end

  def find_direct_chat
    current_user = current_devise_api_token.resource_owner
    user = User.find(params[:id])
    image = user.image.attached? ? url_for(user.image) : nil

    direct_chats = current_user.chats.where(type: 'direct')
    chat = direct_chats.select { |chat_| chat_.participant_ids.include?(user.id) }
    
    render json: chat[0].as_json.merge(name: user.username, image: image)
  end

  def leave_chat
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(params[:id])

    return if !chat.participant_ids.include?(current_user.id)

    participation = chat.chat_participants.where(participant_id: current_user.id)[0]
    if participation.destroy
      user = current_user
      UserChatsChannel.broadcast_to(user, 'change' )
      render json: {message: 'left chat'}, status: :ok
    else
      render json: {message: 'error'}, status: :unprocessable_entity
    end
  end

  def get_addable_users_to_chat
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(params[:id])

    return if chat.admin != current_user

    friends = current_user.friends
    addable_friends = friends.select { |friend| !chat.participants.include?(friend)}
    addable_friends_with_images = addable_friends.map do |friend|
      image = friend.image.attached? ? url_for(friend.image) : nil
      friend.as_json.merge(image: image)
    end

    render json: addable_friends_with_images
  end

  def add_user_to_chat
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(user_chat_params[:chat_id])
    user = User.find(user_chat_params[:user_id])

    return if chat.admin != current_user || chat.participants.include?(user)

    if chat.chat_participants.create(participant_id: user.id)
      UserChatsChannel.broadcast_to(user, 'new' )

      render json: {message: 'user added'}, status: :ok
    else 
      render json: {message: 'error adding user'}, status: :unprocessable_entity
    end
  end

  def remove_user_from_chat
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(user_chat_params[:chat_id])
    user = User.find(user_chat_params[:user_id])

    return if chat.admin != current_user || !chat.participants.include?(user)

    participation = chat.chat_participants.where(participant_id: user.id)[0]
    if participation.destroy
      UserChatsChannel.broadcast_to(user, 'removed chat' )

      render json: {message: 'user removed'}, status: :ok
    else
      render json: {message: 'error removing user from chat'}, status: :unprocessable_entity
    end
  end

  def change_chat_name
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(chat_name_params[:id])

    return if chat.admin != current_user

    if chat.update(name: chat_name_params[:name])
      render json: { message: 'Name updated' }, status: :ok 
    else
      render json: chat.errors, status: :unprocessable_entity
    end
  end

  def change_chat_image
    current_user = current_devise_api_token.resource_owner
    chat = Chat.find(chat_image_params[:id])

    return if chat.admin != current_user

    image = chat_image_params[:image]
    if chat.image.attach(image)
      render json: { message: 'Chat image changed' }, status: :ok 
    else
      render json: chat.errors, status: :unprocessable_entity
    end
  end

  private 
  
  def chat_params
    params.require(:chat).permit(:name, :type)
  end

  def user_chat_params
    params.require(:chat).permit(:chat_id, :user_id)
  end

  def chat_name_params
    params.require(:chat).permit(:name, :id)
  end

  def chat_image_params
    params.require(:chat).permit(:id, :image)
  end
end