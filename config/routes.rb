Rails.application.routes.draw do
  devise_for :users

  get 'chats', to: 'chats#get_all_chats'
  get 'chat_participants/:id', to: 'chats#get_chat_participants'
  get 'public_chats', to: 'chats#get_all_public_chats'
  get 'find_direct_chat/:id', to: 'chats#find_direct_chat'
  get 'get_addable_users_to_chat/:id', to: 'chats#get_addable_users_to_chat'
  post 'create_chat', to: 'chats#create_chat'
  post 'join_public_chat', to: 'chats#join_public_chat'
  post 'leave_chat', to: 'chats#leave_chat'
  post 'add_user_to_chat', to: 'chats#add_user_to_chat'
  post 'remove_user_from_chat', to: 'chats#remove_user_from_chat'
  post 'change_chat_name', to: 'chats#change_chat_name'
  post 'change_chat_image', to: 'chats#change_chat_image'


  get 'get_all_chat_messages/:id', to: 'messages#get_all_chat_messages'
  post 'send_message', to: 'messages#send_message'

  get 'current_user_profile', to: 'profile#current_user_profile'
  get 'search_profiles/:query', to: 'profile#search_profiles'
  post 'change_username', to: 'profile#change_username'
  post 'change_description', to: 'profile#change_description'
  post 'change_profile_image', to: 'profile#change_profile_image'

  get 'get_current_user_friends', to: 'friendships#get_current_user_friends'
  get 'check_friendship_status/:id', to: 'friendships#check_friendship_status'
  post 'send_friend_request', to: 'friendships#send_friend_request'
  post 'cancel_friend_request', to: 'friendships#cancel_friend_request'
  post 'accept_friend_request', to: 'friendships#accept_friend_request'
  post 'remove_friend', to: 'friendships#remove_friend'
end
