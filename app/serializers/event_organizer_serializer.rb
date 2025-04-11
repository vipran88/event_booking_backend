class EventOrganizerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
  
  # Don't include user to avoid circular references
  # has_one :user
  
  # Include events when requested with include parameter
  has_many :events, serializer: EventSerializer
end
