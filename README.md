[![Gem Version](https://badge.fury.io/rb/fabrique.svg)](http://badge.fury.io/rb/fabrique) [![Build Status](https://travis-ci.org/starjuice/fabrique.svg?branch=master)](https://travis-ci.org/starjuice/fabrique) [![Dependency Status](https://gemnasium.com/starjuice/fabrique.svg)](https://gemnasium.com/starjuice/fabrique)

# Fabrique

Factory support library for adapting existing modules for injection as dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fabrique'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fabrique

## Usage

Under construction; hard hat required!

## Puzzling

However plugin factories are composed, the process of constructing a plugin
will be:

```ruby
Properties -> PropertyValidator -> ArgumentAdaptor -> Constructor => plugin`
```

A global function that takes the plugin registration as the composite would
then look like this:

```ruby
def fabricate(registry, plugin_identity, properties)
  registration = registry.find(plugin_identity)
  property_validator = registration.property_validator
  argument_adaptor = registration.argument_adaptor
  constructor = registration.constructor
  plugin_template = registration.template # Currently called the type

  if property_validator.valid?(properties)
    arguments = argument_adaptor.adapt(properties)
    plugin = constructor.construct(plugin_template, arguments)
    return plugin
  else
    raise
  end
end
```

So we might compose thus:

```ruby
# API gem does this
class Store
  def initialize(provider)
    @provider = provider
  end
  # API definition
end
StoreApiFactory = Fabrique::FactoryAdaptor.new(
  template: Store,
  constructor: Constructor::Classical.new,
  argument_adaptor: ArgumentAdaptor::Positional.new(:provider)
)
StoreApiProviderRegistry = Fabrique::Registry.new("Store API Provider Registry")

# Provider gem does this
require "store_api"
class S3StoreProvider
  # API implementation here
end
S3StoreProviderFactory = Fabrique::FactoryAdaptor.new(
  template: S3StoreProvider,
  constructor: Constructor::Classical.new,
  argument_adaptor: ArgumentAdaptor::Keyword.new,
)
StoreApiProviderRegistry.register(:s3, S3StoreProviderFactory)

# API consumer does this
Bundler.require(:default)
provider_factory = StoreApiProviderRegistry.find(:s3)
provider = provider_factory.create(region: "eu-west-1", bucket: "fabrique")
api = StoreApiFactory.create(provider: provider)

# Now, if the API consumer and the API developer agree that this is too high ceremony...

# API gem adds this
class StoreFactory
  def self.create(provider_id: DEFAULT_PROVIDER, provider_properties: DEFAULT_PROVIDER_PROPERTIES)
    provider_factory = StoreApiProviderRegistry.find(:s3)
    provider = provider_factory.create(provider_properties)
    StoreApiFactory.create(provider: provider)
  end
end

# and API consumer just does this
Bundler.require(:default)
api = StoreFactory.create(provider_id: :s3, provider_properties: {region: "eu-west-1", bucket: "fabrique"})
```

Fabrique might be able to offer an easy way to build the low ceremony "provider
API factory". Let's wait and see if high ceremony is really a problem for people.

### Constructors

What kinds of construction process do we care about?

#### Identity

* Makes no sense to use an ArgumentAdaptor (or, by implication, a
  PropertyValidator).

So this is a good pressure to compose everything except Properties
into the Constructor, registered by plugin\_identity.

#### Classical

* Keywords
* Positional
* Builder?

If we say you can mix Classical constructor with Builder ArgumentAdaptor,
then the constructor must call a default constructor only (::new()), passing
in a block.

#### Builder

If we say Builder is a constructor, then it can pass adapted arguments *and*
a block to the adapted constructor.

So, does the world really have constructors that take arguments *and* a
builder block?

#### Lambda?

This could be used to allow *any* adaptation conceivably supported by the
interface of the provider type.

So, are there adaptations we might want that wouldn't be supported by
Identity, Classical and Builder? Yes, surely. But are they *factory*
adaptations? Well...

```ruby
class BadlyDesigned
  def initialize(first_name, last_name)
    @first_name, @last_name = first_name, last_name
  end

  def set_title(title)
    @title = title
  end

  def address
    "#{@name} #{@first_name} #{@last_name}"
  end
end

lambda_constructor = ->(type, properties) do
  type.new(properties).tap { |o| o.set_title(properties[:title]) if properties.include?(:title) }
end
```

But are we in the business of adapting badly designed software for use in
plugin factories? Should the scope perhaps be to adapt well designed software
for use in plugin factories?

## Contributing

1. Fork it ( https://github.com/starjuice/fabrique/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
