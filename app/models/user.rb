class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api

  validates :username, presence: true, length: { in: 4..18 }, uniqueness: true
  validates :description, length: { maximum: 50 }

  has_many :admined_chats, class_name: 'Chat', foreign_key: 'admin_id', dependent: :destroy

  has_many :chat_participants, foreign_key: 'participant_id', dependent: :destroy
  has_many :chats, through: :chat_participants, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, dependent: :destroy

  has_many :incoming_friend_requests, class_name: 'FriendRequest', foreign_key: 'reciever_id', dependent: :destroy
  has_many :incoming_friend_request_senders, through: :incoming_friend_requests, source: :sender, dependent: :destroy
end
