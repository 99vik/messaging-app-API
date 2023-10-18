class Chat < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :admin, class_name: 'User', optional: true
  has_many :chat_participants
  has_many :participants, through: :chat_participants

  validates :name, presence: true, length: { in: 6..30 }
  validates :type, inclusion: { in: %w[public private direct] }
end
