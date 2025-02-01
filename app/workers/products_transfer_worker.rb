class ProductsTransferWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: "default"

  def perform(product_ids, shop)
    @shop_two = Shop.where.not(shopify_domain: shop).first
    session = ShopifyAPI::Auth::Session.new(shop: @shop_two.shopify_domain, access_token: @shop_two.shopify_token)
    ShopifyAPI::Context.activate_session(session)
    @products = []
    product_ids.each do |product|
      @products << ShopifyAPI::Product.find(id: product)
    end
    @shop = Shop.find_by(shopify_domain: shop)
    
    
    session = ShopifyAPI::Auth::Session.new(shop: @shop.shopify_domain, access_token: @shop.shopify_token)
    ShopifyAPI::Context.activate_session(session)
    
    @products.each do |product|
      new_product = ShopifyAPI::Product.new

      new_product.title = product.title
      new_product.body_html = product.body_html
      new_product.vendor = product.vendor
      new_product.product_type = product.product_type
      new_product.tags = product.tags
      new_product.options = product.options&.map do |opt|
        { name: opt["name"], values: opt["values"] }
      end
      new_product.images = product.images&.map { |i| { src: i.src } }
      new_product.metafields = product.metafields&.map do |m|
        { namespace: m.namespace, key: m.key, value: m.value, type: m.type }
      end
      new_product.save!

    end
  end

end
