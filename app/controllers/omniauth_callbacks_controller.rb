class OmniauthCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:google_oauth2]

  def google_oauth2
    auth = request.env['omniauth.auth']
  
    if auth
      # Store credentials in session
      session[:google_credentials] = {
        refresh_token: auth['credentials']['refresh_token'],
        access_token: auth['credentials']['token'],
        expires_at: auth['credentials']['expires_at']
      }
  
      redirect_to root_path, notice: 'Successfully authenticated with Google!'
      # redirect_to campaigns_path, notice: 'Successfully authenticated with Google!'
    else
      redirect_to root_path, alert: 'Authentication failed!'
    end
  end

  def logout
    reset_session # Clear all session data
    redirect_to root_path, notice: 'You have been logged out successfully.'
  end

end
