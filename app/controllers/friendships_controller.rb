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
end
