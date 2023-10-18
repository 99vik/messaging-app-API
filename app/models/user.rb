class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api

  has_many :admined_chats, class_name: 'Chat', foreign_key: 'admin_id', dependent: :destroy

  has_many :chat_participants, foreign_key: 'participant_id'
  has_many :chats, through: :chat_participants
end
