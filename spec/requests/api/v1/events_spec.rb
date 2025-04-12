require 'rails_helper'

RSpec.describe "Api::V1::Events", type: :request do
  let(:event_organizer_user) { create(:user, role: 'event_organizer') }
  let(:event_organizer) { create(:event_organizer, user: event_organizer_user) }
  let(:customer_user) { create(:user, role: 'customer') }
  let(:customer) { create(:customer, user: customer_user) }
  let(:event) { create(:event, event_organizer: event_organizer) }
  let(:valid_headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  describe "GET /api/v1/events" do
    before do
      create_list(:event, 3, event_organizer: event_organizer)
    end

    it "returns all events" do
      get api_v1_events_path, headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "GET /api/v1/events/:id" do
    it "returns the event" do
      get api_v1_event_path(event), headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(event.id)
    end
  end

  describe "POST /api/v1/events" do
    let(:valid_attributes) do
      {
        title: "New Event",
        description: "Event description",
        venue: "Event venue",
        event_date: 1.month.from_now,
        capacity: 100
      }
    end

    context "when authenticated as event organizer" do
      before do
        sign_in event_organizer_user
      end

      it "creates a new event" do
        expect {
          post api_v1_events_path, params: { event: valid_attributes }, headers: valid_headers
        }.to change(Event, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when authenticated as customer" do
      before do
        sign_in customer_user
      end

      it "returns unauthorized" do
        post api_v1_events_path, params: { event: valid_attributes }, headers: valid_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /api/v1/events/:id" do
    let(:new_attributes) do
      {
        title: "Updated Event Title"
      }
    end

    context "when authenticated as event owner" do
      before do
        sign_in event_organizer_user
      end

      it "updates the event" do
        put api_v1_event_path(event), params: { event: new_attributes }, headers: valid_headers
        event.reload
        expect(response).to have_http_status(:ok)
        expect(event.title).to eq("Updated Event Title")
      end
    end

    context "when authenticated as different event organizer" do
      let(:other_organizer_user) { create(:user, role: 'event_organizer') }
      
      before do
        create(:event_organizer, user: other_organizer_user)
        sign_in other_organizer_user
      end

      it "returns forbidden" do
        put api_v1_event_path(event), params: { event: new_attributes }, headers: valid_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/events/:id" do
    context "when authenticated as event owner" do
      before do
        sign_in event_organizer_user
      end

      it "deletes the event" do
        event # create the event
        expect {
          delete api_v1_event_path(event), headers: valid_headers
        }.to change(Event, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
