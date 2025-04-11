class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :role, :created_at
  
  # Include associated models based on user role
  def attributes(*args)
    data = super
    if object.event_organizer?
      data[:event_organizer] = EventOrganizerSerializer.new(object.event_organizer).attributes if object.event_organizer
    elsif object.customer?
      data[:customer] = CustomerSerializer.new(object.customer).attributes if object.customer
    end
    data
  end
end
