class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api

  validates :username, presence: true, length: { in: 4..18 }, uniqueness: true

  has_many :admined_chats, class_name: 'Chat', foreign_key: 'admin_id', dependent: :destroy

  has_many :chat_participants, foreign_key: 'participant_id', dependent: :destroy
  has_many :chats, through: :chat_participants, dependent: :destroy
  has_many :messages, dependent: :destroy
end
