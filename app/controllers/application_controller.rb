class ApplicationController < ActionController::Base
  helper_method :user_signed_in?

  def user_signed_in?
    session[:google_credentials].present?
  end
  
end
