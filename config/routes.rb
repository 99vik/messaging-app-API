Rails.application.routes.draw do
  devise_for :users
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get 'chats', to: 'chats#get_all_chats'
  get 'public_chats', to: 'chats#get_all_public_chats'
  post 'create_chat', to: 'chats#create_chat'
  post 'join_public_chat', to: 'chats#join_public_chat'
end
