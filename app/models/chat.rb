class Chat < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :admin, class_name: 'User', optional: true

  validates :name, presence: true, length: { in: 6..30 }
  validates :type, inclusion: { in: %w[public private direct] }
end
