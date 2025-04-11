class TicketSerializer < ActiveModel::Serializer
  attributes :id, :ticket_type, :price, :quantity_available, :created_at, :updated_at
  
  belongs_to :event
  
  # Format price to ensure it's always displayed with 2 decimal places
  def price
    sprintf('%.2f', object.price) if object.price
  end
  
  # Include total sold tickets count
  def attributes(*args)
    data = super
    data[:total_sold] = object.bookings.sum(:quantity)
    data
  end
end
