class HomeController < ApplicationController
  def index
  end

  def set_credentials
    ENV['GOOGLE_ADS_MANAGER_ID'] = params[:manager_id]

    redirect_to campaigns_path, notice: "Manager ID set to #{ENV['GOOGLE_ADS_MANAGER_ID']}."
  end

  def setup
  end
end
