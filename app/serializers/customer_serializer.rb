class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
  
  # Don't include user to avoid circular references
  # has_one :user
  
  # Include bookings when requested with include parameter
  has_many :bookings, serializer: BookingSerializer
end
