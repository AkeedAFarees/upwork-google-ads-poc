class CampaignsController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :set_credentials
  before_action :set_customer_id
  before_action :set_campaign_id, only: [:show, :create_ad_group, :create_ad]

  def index
    begin
      @campaigns = CampaignsService.new(@credentials).fetch_campaigns(@customer_id)
    rescue StandardError => e
      redirect_to root_path, alert: "Failed to fetch campaigns: #{e.message}"
    end
  end

  def create
    begin
      CampaignsService.new(@credentials).create_campaign(@customer_id)
      redirect_to campaigns_path, notice: 'Campaign successfully created.'
    rescue StandardError => e
      redirect_to root_path, alert: "Failed to create campaign: #{e.message}"
    end
  end

  def show
    begin
      @ad_groups = CampaignsService.new(@credentials).fetch_ad_groups(@customer_id, @campaign_id)
    rescue StandardError => e
      redirect_to root_path, alert: "Failed to open campaign: #{e.message}"
    end
  end

  def create_ad_group
    begin
      CampaignsService.new(@credentials).create_ad_group(@customer_id, @campaign_id)
      redirect_to campaign_path(@campaign_id), notice: 'Ad group successfully created.'
    rescue StandardError => e
      redirect_to root_path, alert: "Failed to create ad group: #{e.message}"
    end
  end

  def create_ad
    begin
      CampaignsService.new(@credentials).create_ad(@customer_id, @campaign_id, params[:ad_group_id])
      redirect_to campaign_path(@campaign_id), notice: 'Ad successfully created.'
    rescue StandardError => e
      redirect_to root_path, alert: "Failed to create ad: #{e.message}"
    end
  end

  private

  def ensure_user_signed_in
    redirect_to root_path, alert: 'Please log in with Google first.' unless user_signed_in?
  end

  def set_credentials
    @credentials = session[:google_credentials]
  end

  def set_customer_id
    @customer_id = ENV['GOOGLE_ADS_MANAGER_ID']
  end

  def set_campaign_id
    @campaign_id = params[:id]
  end
end
