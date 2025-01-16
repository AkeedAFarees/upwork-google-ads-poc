class User < ApplicationRecord

  # Token expiry check
  def google_token_expired?
    google_expires_at < Time.now
  end

  # Refresh the Google token if expired
  def refresh_google_token
    # Set up the Google Ads API client
    client = Google::Ads::GoogleAds::GoogleAdsClient.new

    # Use the refresh_token to obtain a new access token
    credentials = client.configuration.credentials
    response = credentials.refresh!
    
    # Update the user with the new token
    self.update(google_token: response.token)
  end
  
end
