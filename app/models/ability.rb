class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here
    user ||= User.new # guest user (not logged in)
    
    # Set permissions based on user role
    if user.event_organizer?
      # Event Organizers can manage their own events and tickets
      can :manage, Event, event_organizer: { user_id: user.id }
      can :manage, Ticket, event: { event_organizer: { user_id: user.id } }
      can :read, Booking, ticket: { event: { event_organizer: { user_id: user.id } } }
    elsif user.customer?
      # Customers can view events and tickets, and manage their own bookings
      can :read, Event
      can :read, Ticket
      can [:create, :read, :destroy], Booking, customer: { user_id: user.id }
    end
    
    # Everyone can read public events
    can :read, Event, public: true
  end
end
