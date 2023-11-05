class UserChatsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_#{params[:user_id]}"

    # user = User.find(params[:user_id])
    # stream_for user

    # chat_ids = params[:chat_ids].uniq
    # chat_ids.each do |chat_id|
    #   chat = Chat.find(chat_id)
    #   stream_for chat
    # end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
