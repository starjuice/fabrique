[![Gem Version](https://badge.fury.io/rb/fabrique.svg)](http://badge.fury.io/rb/fabrique) [![Build Status](https://travis-ci.org/starjuice/fabrique.svg?branch=master)](https://travis-ci.org/starjuice/fabrique) [![Dependency Status](https://gemnasium.com/starjuice/fabrique.svg)](https://gemnasium.com/starjuice/fabrique)

# Fabrique

Configuration-based factory for dependency injection.
Inspired by Java [spring beans](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/beans.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fabrique'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fabrique

## Testing

```shell
git clone git@github.com/starjuice/fabrique.git
cd fabrique
bundle
bundle exec rake
```

The test coverage is superficial at the moment. When working with features/bean_factory.feature,
keep in mind that some exceptions are caught and stored as instance variables to be evlauated by
subsequent steps. This avoids some English contortions, but the down side is that if you introduce
a regression that raises an exception in a scenario that doesn't expect one, you won't see the
exception. To log exceptions, even when they are expected:

```shell
DEBUG=1 bundle exec rake
```

## Usage

Under construction; hard hat required!

The best source of documentation of what's possible in the configuration of Fabrique::BeanFactory is currently
features/bean\_factory.feature. But reading the step definitions for an example of usage would be awkward, so
here is a code example.

Given this example YAML application context definition,
in a file called application\_context.yml:

```yaml
---
beans:
- id: customer_repository
  class: Fabrique::Test::Fixtures::Repository::CustomerRepository
  constructor_args:
    - !bean/ref store
    - !bean/ref customer_data_mapper
- id: product_repository
  class: Fabrique::Test::Fixtures::Repository::ProductRepository
  constructor_args:
    store: !bean/ref store
    data_mapper: !bean/ref product_data_mapper
- id: store
  class: Fabrique::Test::Fixtures::Repository::MysqlStore
  constructor_args:
    host: localhost
    port: 3306
- id: customer_data_mapper
  class: Fabrique::Test::Fixtures::Repository::CustomerDataMapper
  scope: prototype
- id: product_data_mapper
  class: Fabrique::Test::Fixtures::Repository::ProductDataMapper
  scope: prototype
```

Here is how we could materialize these dependencies:

```ruby
bean_factory = Fabrique::YamlBeanFactory.new(File.read('application_context.yml'))

customer_service = CustomerService.new(repository: bean_factory.get_bean('customer_repository'))
product_service = ProductService.new(repository: bean_factory.get_bean('product_repository'))
store_service = StoreService.new(customers: customer_service, products: product_service)
# ...
```

Of course, the construction of these services could just as well have been handled by the
bean factory as well. Where to draw the line is an interesting topic. The example above draws it
"at dependencies of everything but main".

For a data-centric approach to IoC, the entire set of beans can be materialized as a dictionary
and made available to consumer to cherry-pick what they need without any awareness of the use
of a BeanFactory:

```ruby
bean_factory = Fabrique::YamlBeanFactory.new('application_context.yml')
# Symbolize keys for use as keyword arguments:
context = bean_factory.to_h.map { |k, v| [k.intern, v] }.to_h

store_service = StoreService.new(context)
```
