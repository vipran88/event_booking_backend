require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:venue) }
    it { should validate_presence_of(:event_date) }
    it { should validate_presence_of(:capacity) }
  end

  describe 'associations' do
    it { should belong_to(:event_organizer) }
    it { should have_many(:tickets) }
    it { should have_many(:bookings).through(:tickets) }
  end

  describe 'scopes' do
    let!(:past_event) { create(:event, event_date: 1.day.ago) }
    let!(:future_event) { create(:event, event_date: 1.day.from_now) }

    it 'returns upcoming events' do
      expect(Event.upcoming).to include(future_event)
      expect(Event.upcoming).not_to include(past_event)
    end

    it 'returns past events' do
      expect(Event.past).to include(past_event)
      expect(Event.past).not_to include(future_event)
    end
  end
end
