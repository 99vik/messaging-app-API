class FriendshipsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!

  def get_current_user_friends
    current_user = current_devise_api_token.resource_owner

    if current_user
      render json: current_user.friends, only: [:id, :username, :description]
    else
      render json: { message: 'error' }, status: :unprocessable_entity
    end
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
      chat[0].destroy

      render json: { message: 'removed friend' }
    end
  end
end
