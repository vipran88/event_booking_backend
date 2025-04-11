class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :venue, :event_date, :capacity, :created_at, :updated_at
  
  belongs_to :event_organizer
  has_many :tickets
  
  # Custom method to format event_date
  def event_date
    object.event_date.strftime('%Y-%m-%d %H:%M:%S') if object.event_date
  end
  
  # Include total available tickets count
  def attributes(*args)
    data = super
    data[:total_tickets_available] = object.tickets.sum(:quantity_available)
    data
  end
end
