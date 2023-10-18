class ChatParticipant < ApplicationRecord
  belongs_to :chat
  belongs_to :participant, class_name: 'User'
end
