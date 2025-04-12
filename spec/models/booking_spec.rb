require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:customer) }
    it { should belong_to(:ticket) }
  end

  describe 'callbacks' do
    let(:ticket) { create(:ticket, price: 25.0, quantity_available: 10) }
    let(:customer) { create(:customer) }

    it 'calculates total price before save' do
      booking = build(:booking, ticket: ticket, customer: customer, quantity: 3, total_price: nil)
      booking.save
      expect(booking.total_price).to eq(75.0) # 3 * 25.0
    end

    it 'updates ticket availability after create' do
      expect {
        create(:booking, ticket: ticket, customer: customer, quantity: 3)
      }.to change { ticket.reload.quantity_available }.by(-3)
    end
  end
end
