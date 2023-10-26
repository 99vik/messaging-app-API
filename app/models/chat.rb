class Chat < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :admin, class_name: 'User', optional: true
  has_many :chat_participants, dependent: :destroy
  has_many :participants, through: :chat_participants

  validates :type, inclusion: { in: %w[public private direct] }
  validates :name, presence: true, length: { in: 6..30 }, if: :chat_not_direct?
  has_many :messages

  def chat_not_direct?
    type != 'direct'
  end
end
