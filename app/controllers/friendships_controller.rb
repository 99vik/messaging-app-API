class FriendshipsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authenticate_devise_api_token!

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
  end

  def remove_friend
  end
end
