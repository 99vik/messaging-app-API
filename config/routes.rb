Rails.application.routes.draw do
  devise_for :users

  get 'chats', to: 'chats#get_all_chats'
  get 'public_chats', to: 'chats#get_all_public_chats'
  get 'find_direct_chat/:id', to: 'chats#find_direct_chat'
  post 'create_chat', to: 'chats#create_chat'
  post 'join_public_chat', to: 'chats#join_public_chat'

  get 'get_all_chat_messages/:id', to: 'messages#get_all_chat_messages'
  post 'send_message', to: 'messages#send_message'

  get 'current_user_profile', to: 'profile#current_user_profile'
  get 'search_profiles/:query', to: 'profile#search_profiles'
  post 'change_username', to: 'profile#change_username'
  post 'change_description', to: 'profile#change_description'

  get 'get_current_user_friends', to: 'friendships#get_current_user_friends'
  get 'check_friendship_status/:id', to: 'friendships#check_friendship_status'
  post 'send_friend_request', to: 'friendships#send_friend_request'
  post 'cancel_friend_request', to: 'friendships#cancel_friend_request'
  post 'accept_friend_request', to: 'friendships#accept_friend_request'
  post 'remove_friend', to: 'friendships#remove_friend'
end
