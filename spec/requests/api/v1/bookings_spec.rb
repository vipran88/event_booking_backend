require 'rails_helper'

RSpec.describe "Api::V1::Bookings", type: :request do
  let(:customer_user) { create(:user, role: 'customer') }
  let(:customer) { create(:customer, user: customer_user) }
  let(:event_organizer_user) { create(:user, role: 'event_organizer') }
  let(:event_organizer) { create(:event_organizer, user: event_organizer_user) }
  let(:event) { create(:event, event_organizer: event_organizer) }
  let(:ticket) { create(:ticket, event: event, price: 25.0, quantity_available: 10) }
  let(:booking) { create(:booking, customer: customer, ticket: ticket, quantity: 2) }
  
  let(:valid_headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  describe "GET /api/v1/bookings" do
    before do
      create_list(:booking, 3, customer: customer, ticket: ticket)
    end

    context "when authenticated as customer" do
      before do
        sign_in customer_user
      end

      it "returns customer's bookings" do
        get api_v1_bookings_path, headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context "when authenticated as event organizer" do
      before do
        sign_in event_organizer_user
      end

      it "returns bookings for organizer's events" do
        get api_v1_bookings_path, headers: valid_headers
        expect(response).to have_http_status(:ok)
        # Event organizers should see bookings for their events
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end
  end

  describe "GET /api/v1/bookings/:id" do
    context "when authenticated as booking owner" do
      before do
        sign_in customer_user
      end

      it "returns the booking" do
        get api_v1_booking_path(booking), headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(booking.id)
      end
    end

    context "when authenticated as different customer" do
      let(:other_customer_user) { create(:user, role: 'customer') }
      
      before do
        create(:customer, user: other_customer_user)
        sign_in other_customer_user
      end

      it "returns forbidden" do
        get api_v1_booking_path(booking), headers: valid_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/bookings" do
    let(:valid_attributes) do
      {
        ticket_id: ticket.id,
        quantity: 2
      }
    end

    context "when authenticated as customer" do
      before do
        sign_in customer_user
      end

      it "creates a new booking" do
        expect {
          post api_v1_bookings_path, params: { booking: valid_attributes }, headers: valid_headers
        }.to change(Booking, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "calculates the total price correctly" do
        post api_v1_bookings_path, params: { booking: valid_attributes }, headers: valid_headers
        expect(JSON.parse(response.body)['total_price']).to eq('50.0')
      end

      it "decreases ticket availability" do
        expect {
          post api_v1_bookings_path, params: { booking: valid_attributes }, headers: valid_headers
          ticket.reload
        }.to change(ticket, :quantity_available).by(-2)
      end
    end

    context "when not enough tickets available" do
      before do
        sign_in customer_user
      end

      it "returns unprocessable entity" do
        post api_v1_bookings_path, params: { booking: { ticket_id: ticket.id, quantity: 20 } }, headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/bookings/:id" do
    context "when authenticated as booking owner" do
      before do
        sign_in customer_user
      end

      it "cancels the booking" do
        booking # create the booking
        expect {
          delete api_v1_booking_path(booking), headers: valid_headers
          ticket.reload
        }.to change(ticket, :quantity_available).by(2)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when authenticated as different customer" do
      let(:other_customer_user) { create(:user, role: 'customer') }
      
      before do
        create(:customer, user: other_customer_user)
        sign_in other_customer_user
      end

      it "returns forbidden" do
        delete api_v1_booking_path(booking), headers: valid_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
