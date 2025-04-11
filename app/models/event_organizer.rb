class EventOrganizer < ApplicationRecord
  belongs_to :user, optional: true
  has_many :events
  
  # Delegate authentication to User model
  delegate :email, :password, :password_confirmation, to: :user, allow_nil: true
end
