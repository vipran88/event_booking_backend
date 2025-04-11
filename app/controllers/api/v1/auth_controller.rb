class Api::V1::AuthController < Api::V1::BaseController
  # Skip authentication for registration and login
  skip_before_action :authenticate_user!, only: [:register, :login]
  
  # POST /api/v1/auth/register
  def register
    # Create a new User with the specified role
    @user = User.new(email: params[:email], password: params[:password], 
                     password_confirmation: params[:password_confirmation], 
                     role: params[:role])
    
    if @user.save
      # Create the associated profile based on role
      if @user.event_organizer?
        @profile = EventOrganizer.create(name: params[:name], user: @user)
      elsif @user.customer?
        @profile = Customer.create(name: params[:name], user: @user)
      end
      
      # Generate JWT token
      token = request.env['warden-jwt_auth.token']
      
      render json: {
        message: 'Registration successful',
        user: ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer),
        token: token
      }, status: :created
    else
      render_error(@user.errors.full_messages.join(', '))
    end
  end
  
  # POST /api/v1/auth/login
  def login
    # Find user by email
    @user = User.find_by(email: params[:email])
    
    # Check if user exists and password is correct
    if @user && @user.valid_password?(params[:password])
      # Use Devise's built-in sign_in method to handle JWT token generation
      sign_in(@user)
      
      # Get JWT token from warden
      token = request.env['warden-jwt_auth.token']
      
      render json: {
        message: 'Login successful',
        user: ActiveModelSerializers::SerializableResource.new(@user, serializer: UserSerializer),
        token: token
      }
    else
      render_error('Invalid email or password', :unauthorized)
    end
  end
  
  # DELETE /api/v1/auth/logout
  def logout
    # JWT token will be automatically added to denylist by Devise JWT
    sign_out(current_user)
    render json: { message: 'Logout successful' }
  end
  
  private
  
  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :role)
  end
end
