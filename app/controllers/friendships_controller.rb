class FriendshipsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!

  def get_current_user_friends
    current_user = current_devise_api_token.resource_owner

    if current_user
      friends = current_user.friends.select(:id, :username, :description)
      friends_with_images = friends.map do |friend|
        image = friend.image.attached? ? url_for(friend.image) : nil
        friend.as_json.merge(image: image)
      end
      render json: friends_with_images
    else
      render json: { message: 'error' }, status: :unprocessable_entity
    end
  end

  def get_friend_requests
    current_user = current_devise_api_token.resource_owner

    requests = current_user.incoming_friend_requests
    requests_with_user = requests.map do |request|
      user = request.sender
      image = user.image.attached? ? url_for(user.image) : nil
      user.as_json.merge(image: image)
      request.as_json.merge(user: {description: user.description, id: user.id, username: user.username, image: image})
    end
    render json: requests_with_user
  end

  def check_friendship_status
    current_user = current_devise_api_token.resource_owner
    user = User.find(params[:id])

    if current_user.friends.include?(user)
      render json: { status: 'friends' }
    elsif current_user.incoming_friend_request_senders.include?(user)
      render json: { status: 'incoming' }
    elsif user.incoming_friend_request_senders.include?(current_user)
      render json: { status: 'outgoing' }
    else 
      render json: { status: 'none' }
    end
  end

  def send_friend_request
    current_user = current_devise_api_token.resource_owner
    user = User.find(params[:friendship][:id])

    if current_user.friends.include?(user) || current_user.incoming_friend_request_senders.include?(user) || user.incoming_friend_request_senders.include?(current_user)
      render json: { message: 'error' }, status: :unprocessable_entity
    else
      FriendRequest.create(sender_id: current_user.id, reciever_id: user.id)
      render json: { status: 'sent' }, status: :ok
    end
  end

  def cancel_friend_request
    current_user = current_devise_api_token.resource_owner
    user = User.find(params[:friendship][:id])

    if !user.incoming_friend_request_senders.include?(current_user)
      render json: { message: 'error' }, status: :unprocessable_entity
    else
      request = FriendRequest.where(sender_id: current_user.id, reciever_id: user.id).first
      if request.destroy
        render json: { status: 'canceled' }, status: :ok
      else
        render json: { message: 'error' }, status: :unprocessable_entity
      end
    end
  end

  def accept_friend_request
    current_user = current_devise_api_token.resource_owner
    user = User.find(params[:friendship][:id])

    if !current_user.incoming_friend_request_senders.include?(user)
      render json: { message: 'error' }, status: :unprocessable_entity
    else
      request = FriendRequest.where(sender_id: user.id, reciever_id: current_user.id).first
      request.destroy

      Friendship.create(user_id: current_user.id, friend_id: user.id)
      Friendship.create(user_id: user.id, friend_id: current_user.id)

      chat = Chat.create(type: 'direct')
      chat.chat_participants.create(participant_id: current_user.id)
      chat.chat_participants.create(participant_id: user.id)
      [current_user, user].each do |user| 
        UserChatsChannel.broadcast_to(user, {id: chat.id} )
      end

      
      render json: { status: 'added' }, status: :ok
    end
  end

  def remove_friend
    current_user = current_devise_api_token.resource_owner
    user = User.find(params[:friendship][:id])

    if !current_user.friends.include?(user)
      render json: { message: 'error' }, status: :unprocessable_entity
    else
      friendships = Friendship.where(user: current_user.id, friend: user.id).or(Friendship.where(user: user.id, friend: current_user.id))
      friendships.each {|friendship| friendship.destroy }

      direct_chats = current_user.chats.where(type: 'direct')
      chat = direct_chats.select { |chat_| chat_.participant_ids.include?(user.id) }
      chat_id = chat[0].id
      chat[0].destroy
      [current_user, user].each do |user| 
        UserChatsChannel.broadcast_to(user, {remove_id: chat_id} )
      end

      render json: { message: 'removed friend' }
    end
  end
end
