require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
  end

  describe 'associations' do
    it 'can have an event_organizer profile' do
      user = create(:user, role: 'event_organizer')
      event_organizer = create(:event_organizer, user: user)
      expect(user.event_organizer).to eq(event_organizer)
    end

    it 'can have a customer profile' do
      user = create(:user, role: 'customer')
      customer = create(:customer, user: user)
      expect(user.customer).to eq(customer)
    end
  end

  describe 'role methods' do
    it 'identifies as event_organizer when role is event_organizer' do
      user = build(:user, role: 'event_organizer')
      expect(user.event_organizer?).to be true
      expect(user.customer?).to be false
    end

    it 'identifies as customer when role is customer' do
      user = build(:user, role: 'customer')
      expect(user.customer?).to be true
      expect(user.event_organizer?).to be false
    end
  end
end
