class UserChatsChannel < ApplicationCable::Channel
  def subscribed
    user = User.find(params[:user_id])
    stream_for user
    
    chat_ids = params[:chat_ids]
    chat_ids.each do |chat_id|
      chat = Chat.find(chat_id)
      stream_for chat
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
