class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
         
  # Define valid roles
  ROLES = %w[event_organizer customer]
  
  # Validations
  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role" }
  
  # Associations
  has_one :event_organizer, dependent: :destroy
  has_one :customer, dependent: :destroy
  
  # Role methods
  def event_organizer?
    role == 'event_organizer'
  end
  
  def customer?
    role == 'customer'
  end
end
