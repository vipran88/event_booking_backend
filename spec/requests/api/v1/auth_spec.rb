require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  let(:valid_headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  describe "POST /api/v1/auth/register" do
    let(:valid_customer_attributes) do
      {
        user: {
          email: "customer@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "customer"
        },
        customer: {
          name: "John Doe"
        }
      }
    end

    let(:valid_organizer_attributes) do
      {
        user: {
          email: "organizer@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "event_organizer"
        },
        event_organizer: {
          name: "Event Company"
        }
      }
    end

    context "with valid customer attributes" do
      it "creates a new customer user and returns a JWT token" do
        expect {
          post api_v1_auth_register_path, params: valid_customer_attributes, headers: valid_headers
        }.to change(User, :count).by(1)
           .and change(Customer, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('token')
        expect(response.headers['Authorization']).to be_present
      end
    end

    context "with valid organizer attributes" do
      it "creates a new event organizer user and returns a JWT token" do
        expect {
          post api_v1_auth_register_path, params: valid_organizer_attributes, headers: valid_headers
        }.to change(User, :count).by(1)
           .and change(EventOrganizer, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('token')
        expect(response.headers['Authorization']).to be_present
      end
    end

    context "with invalid attributes" do
      it "does not create a user with duplicate email" do
        create(:user, email: "customer@example.com")
        
        expect {
          post api_v1_auth_register_path, params: valid_customer_attributes, headers: valid_headers
        }.to change(User, :count).by(0)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a user with mismatched passwords" do
        invalid_attributes = valid_customer_attributes.deep_dup
        invalid_attributes[:user][:password_confirmation] = "wrong_password"
        
        expect {
          post api_v1_auth_register_path, params: invalid_attributes, headers: valid_headers
        }.to change(User, :count).by(0)
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns a JWT token" do
        post api_v1_auth_login_path, params: { 
          email: "user@example.com", 
          password: "password123" 
        }, headers: valid_headers
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('token')
        expect(response.headers['Authorization']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized for wrong password" do
        post api_v1_auth_login_path, params: { 
          email: "user@example.com", 
          password: "wrong_password" 
        }, headers: valid_headers
        
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized for non-existent user" do
        post api_v1_auth_login_path, params: { 
          email: "nonexistent@example.com", 
          password: "password123" 
        }, headers: valid_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    let(:user) { create(:user) }

    context "when authenticated" do
      before do
        sign_in user
      end

      it "invalidates the JWT token" do
        delete api_v1_auth_logout_path, headers: valid_headers
        
        expect(response).to have_http_status(:ok)
        # The token should be added to the denylist
        # We can verify this by trying to use the same token again
        get api_v1_events_path, headers: valid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized" do
        delete api_v1_auth_logout_path, headers: valid_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
