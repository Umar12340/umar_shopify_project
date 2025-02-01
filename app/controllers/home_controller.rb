# frozen_string_literal: true

class HomeController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::EnsureInstalled
  include ShopifyApp::ShopAccessScopesVerification
  skip_before_action :verify_authenticity_token, only: [:transfer_products]

  def index
    if ShopifyAPI::Context.embedded? && (!params[:embedded].present? || params[:embedded] != "1")
      redirect_to(ShopifyAPI::Auth.embedded_app_url(params[:host]) + request.path, allow_other_host: true)
    else
      @shops = Shop.where.not(shopify_domain: current_shopify_domain)
      @shop_origin = current_shopify_domain
      @host = params[:host]
    end
  end

  def transfer_products
    
  end
end
