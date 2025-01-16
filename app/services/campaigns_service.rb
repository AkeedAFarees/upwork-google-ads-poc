require 'google/ads/google_ads'
require 'logger'
require 'date'

class CampaignsService

  def initialize(credentials)
    @client = Google::Ads::GoogleAds::GoogleAdsClient.new do |config|
      config.api_endpoint = ENV['GOOGLE_ADS_API_ENDPOINT']
      config.client_id = ENV['GOOGLE_CLIENT_ID']
      config.client_secret = ENV['GOOGLE_CLIENT_SECRET']
      config.refresh_token = credentials['refresh_token']
      config.developer_token = ENV['GOOGLE_ADS_DEVELOPER_TOKEN']
      config.login_customer_id = ENV['GOOGLE_ADS_MANAGER_ID']
      # config.linked_customer_id = ENV['GOOGLE_ADS_CLIENT_ID']
      config.logger = Logger.new(STDOUT)
    end
  end

  def fetch_campaigns(customer_id)
    begin
      query = 'SELECT 
        campaign.id, 
        campaign.name,
        campaign.status,
        campaign.start_date,
        campaign.end_date
      FROM campaign 
      ORDER BY campaign.id'
      campaigns = []

      responses = @client.service.google_ads.search_stream(customer_id: customer_id, query: query)
      responses.each do |response|
        response.results.each do |row|
          campaigns << { 
            id:   row.campaign.id, 
            name: row.campaign.name,
            status: row.campaign.status,
            start_date: row.campaign.start_date,
            end_date: row.campaign.end_date
          }
        end
      end

      campaigns
    rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
      Rails.logger.error("Google Ads API Error: #{e.message}")
      raise e
    end
  end

  def create_campaign(customer_id)
    begin
      # Create a budget, which can be shared by multiple campaigns.
      campaign_budget = @client.resource.campaign_budget do |cb|
        cb.name = "Budget #{Faker::Number.number(digits: 5)}"
        cb.delivery_method = :STANDARD
        cb.amount_micros = 1_000_000
      end
    
      operation = @client.operation.create_resource.campaign_budget(campaign_budget)
    
      # Add budget.
      return_budget = @client.service.campaign_budget.mutate_campaign_budgets(
        customer_id: customer_id,
        operations: [operation],
      )
    
      # Create campaign.
      campaign = @client.resource.campaign do |c|
        c.name = "Campaign #{Faker::Marketing.buzzwords}"
        c.advertising_channel_type = :SEARCH
    
        # Recommendation: Set the campaign to PAUSED when creating it to prevent
        # the ads from immediately serving. Set to ENABLED once you've added
        # targeting and the ads are ready to serve.
        c.status = :PAUSED
    
        # Set the bidding strategy and budget.
        c.manual_cpc = @client.resource.manual_cpc
        c.campaign_budget = return_budget.results.first.resource_name
    
        # Set the campaign network options.
        c.network_settings = @client.resource.network_settings do |ns|
          ns.target_google_search = true
          ns.target_search_network = true
          # Enable Display Expansion on Search campaigns. See
          # https://support.google.com/google-ads/answer/7193800 to learn more.
          ns.target_content_network = true
          ns.target_partner_search_network = false
        end
    
        # Optional: Set the start date.
        c.start_date = DateTime.parse((Date.today + 1).to_s).strftime('%Y%m%d')
    
        # Optional: Set the end date.
        c.end_date = DateTime.parse((Date.today.next_year).to_s).strftime('%Y%m%d')
      end
    
      # Create the operation.
      campaign_operation = @client.operation.create_resource.campaign(campaign)
    
      # Add the campaign.
      response = @client.service.campaign.mutate_campaigns(
        customer_id: customer_id,
        operations: [campaign_operation],
      )
    
      puts "Created campaign #{response.results.first.resource_name}."
    rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
      Rails.logger.error("Google Ads API Error: #{e.message}")
      raise e
    end
  end

  def fetch_ad_groups(customer_id, campaign_id)
    begin
      # Step 1: Get all ad groups under the given campaign
      ad_groups_query = <<-QUERY
        SELECT
          ad_group.id,
          ad_group.name,
          ad_group.status
        FROM
          ad_group
        WHERE
          ad_group.campaign = "#{@client.path.campaign(customer_id, campaign_id)}"
      QUERY
    
      ad_groups = []
    
      # Fetch ad groups
      responses = @client.service.google_ads.search_stream(customer_id: customer_id, query: ad_groups_query)
      responses.each do |response|
        response.results.each do |row|
          ad_groups << { id: row.ad_group.id, name: row.ad_group.name, status: row.ad_group.status, ads: [] }
        end
      end
    
      # Step 2: For each ad group, fetch the ads within that ad group
      ad_groups.each do |ad_group|
        query = <<-QUERY
          SELECT
            ad_group_ad.ad.id,
            ad_group_ad.ad.name,
            ad_group_ad.status,
            ad_group_ad.ad.responsive_search_ad.headlines
          FROM
            ad_group_ad
          WHERE
            ad_group_ad.ad_group = "#{@client.path.ad_group(customer_id, ad_group[:id])}"
        QUERY
    
        # Fetch ads within each ad group
        response = @client.service.google_ads.search(customer_id: customer_id, query: query)
        response.each do |row|
          ad_group[:ads] << {
            id: row.ad_group_ad.ad.id,
            name: row.ad_group_ad.ad.name,
            status: row.ad_group_ad.status,
            headlines: row.ad_group_ad.ad.responsive_search_ad.headlines.map(&:text)
          }
        end
      end
    
      ad_groups
    rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
      Rails.logger.error("Google Ads API Error: #{e.message}")
      raise e
    end    
  end  

  def create_ad_group(customer_id, campaign_id)
    begin
      ad_group = @client.resource.ad_group do |ag|
        ag.name = "Ad Group #{Faker::Marketing.buzzwords}"
        ag.status = :ENABLED
        ag.campaign = @client.path.campaign(customer_id, campaign_id)
        ag.type = :SEARCH_STANDARD
        ag.cpc_bid_micros = 1_000_000
      end
    
      # Create the operation
      ad_group_operation = @client.operation.create_resource.ad_group(ad_group)
    
      # Add the ad group.
      response = @client.service.ad_group.mutate_ad_groups(
        customer_id: customer_id,
        operations: [ad_group_operation],
      )
    
      puts "Created ad group #{response.results.first.resource_name}."
    rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
      Rails.logger.error("Google Ads API Error: #{e.message}")
      raise e
    end
  end

  def create_ad(customer_id, campaign_id, ad_group_id)
    begin
      # Create an ad with headlines, descriptions, and final URLs
      ad = @client.resource.ad do |ad|
        ad.final_urls << Faker::Internet.url(host: 'example.com')
        ad.responsive_search_ad = @client.resource.responsive_search_ad_info do |rsa|
          # Generate and validate headlines
          headlines = [
            Faker::Marketing.buzzwords[0..29],  # Ensure <= 30 characters
            Faker::Company.catch_phrase[0..29],
            Faker::Commerce.department[0..29]
          ]
          headlines.each do |headline|
            rsa.headlines << @client.resource.ad_text_asset { |hta| hta.text = headline }
          end
      
          # Generate and validate descriptions
          descriptions = [
            Faker::Lorem.sentence(word_count: 10)[0..89],  # Ensure <= 90 characters
            Faker::Lorem.sentence(word_count: 12)[0..89]
          ]
          descriptions.each do |description|
            rsa.descriptions << @client.resource.ad_text_asset { |dta| dta.text = description }
          end
        end
      end
  
      # Create the AdGroupAd
      ad_group_ad = @client.resource.ad_group_ad do |aga|
        aga.ad = ad
        aga.status = :PAUSED # Set initial status; can be ENABLED
        aga.ad_group = @client.path.ad_group(customer_id, ad_group_id)
      end
  
      # Create the operation
      ad_group_ad_operation = @client.operation.create_resource.ad_group_ad(ad_group_ad)
  
      # Send the request to create the ad
      response = @client.service.ad_group_ad.mutate_ad_group_ads(
        customer_id: customer_id,
        operations: [ad_group_ad_operation],
      )
  
      puts "Created responsive search ad with resource name #{response.results.first.resource_name}."
    rescue Google::Ads::GoogleAds::Errors::GoogleAdsError => e
      Rails.logger.error("Google Ads API Error: #{e.message}")
      raise e
    end
  end
  
end
