class BookingSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :total_price, :created_at, :updated_at
  
  belongs_to :customer
  belongs_to :ticket
  
  # Format total_price to ensure it's always displayed with 2 decimal places
  def total_price
    sprintf('%.2f', object.total_price) if object.total_price
  end
  
  # Include event details for convenience
  def attributes(*args)
    data = super
    if object.ticket&.event
      data[:event] = {
        id: object.ticket.event.id,
        title: object.ticket.event.title,
        venue: object.ticket.event.venue,
        event_date: object.ticket.event.event_date&.strftime('%Y-%m-%d %H:%M:%S')
      }
    end
    data
  end
end
