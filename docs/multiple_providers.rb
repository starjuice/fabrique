# Stretch the design to support multiple providers

# The API gem does this
class InvoiceService
  def initialize(billing_provider, asset_provider, options = {})
    @billing_provider, @asset_provider, @options = billing_provider, asset_provider, options
  end

  def business_method
    @asset_provider.get_all_assets.map do |asset|
      @billing_provider.get_billing_for_asset(asset).tap do |billing|
        if !@options[:dry_run]
          @billing_provider.invoice_billing(billing)
        end
      end
    end
  end
end
InvoiceServiceApiFactory = Fabrique::FactoryAdaptor::Method.new(
  template: InvoiceService,
  method: :new,
  arguments: Fabrique::ArgumentAdaptor::Positional.new(:billing_provider, :asset_provider, [:properties])
)
InvoiceServiceProviderFactoryRegistry = Fabrique::Registry.new(name: "Invoice service billing provider registry", index_components: 2)

# A billing provider gem does this
require "invoice_service"
class FreshBooksBillingProvider
  def initialize(options = {})
    #...
  end

  def get_billing_for_asset(asset)
    {
      asset: asset,
      #...
    }
  end

  def invoice_billing(billing)
    #...
  end
end
FreshBooksBillingProviderFactory = Fabrique::FactoryAdaptor::Method.new(
  template: FreshBooksBillingProvider,
  method: :new,
  arguments: Fabrique::ArgumentAdaptor::Keyword.new
)
InvoiceServiceProviderFactoryRegistry.register("billing", "freshbooks", FreshBooksBillingProviderFactory)

# An asset provider gem does this
require "invoice_service"
class AssetPointAssetProvider
  def initialize(host: nil, port: nil, username: nil, password: nil)
    #...
  end

  def get_all_assets
    [
      #...
    ]
  end
end
AssetPointAssetProviderFactory = Fabrique::FactoryAdaptor::Method.new(
  template: AssetPointAssetProviderFactory,
  method: :new,
  arguments: Fabrique::ArgumentAdaptor::Keyword.new(:host, :port, :username, :password)
)
InvoiceServiceProviderFactoryRegistry.register("asset", "assetpoint", AssetPointAssetProviderFactory)

# API consumer does this
Bundler.require(:default)
api = InvoiceServiceApiFactory.create(
  billing_provider: InvoiceServiceProviderFactoryRegistry.find("billing", config.get_string("billing_provider")).create(
    config.get_properties("billing_provider_properties")
  ),
  asset_provider: InvoiceServiceProviderFactoryRegistry.find("asset", config.get_string("asset_provider")).create(
    config.get_properties("asset_provider_properties")
  )
  properties: {dry_run: true}
)

# Now, if the API consumer and the API developer agree that this is too high ceremony...

# API gem adds this
InvoiceServiceFactory = Fabrique::Factory::PluggableApi.new(
  api_factory: InvoiceServiceApiFactory,
  providers: {
    billing_provider: {registry: InvoiceServiceProviderFactoryRegistry, index_prefix: ["billing"]},
    asset_provider: {registry: InvoiceServiceProviderFactoryRegistry, index_prefix: ["asset"]},
  }
)

# and API consumer just does this
Bundler.require(:default)
api = InvoiceServiceFactory.create(
  billing_provider: config.get_string("billing_provider"),
  billing_provider_properties: config.get_string("billing_provider_properties"),
  asset_provider: config.get_string("asset_provider"),
  asset_provider_properties: config.get_string("asset_provider_properties"),
  properties: {dry_run: true}
)

# Hmmm. That certainly doesn't pay for itself! Screw it, let's just implement Spring Beans for Ruby.
