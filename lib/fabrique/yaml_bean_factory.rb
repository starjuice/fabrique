require "yaml"
require_relative "bean_definition_registry"
require_relative "bean_definition"
require_relative "bean_factory"
require_relative "bean_reference"
require_relative "bean_property_reference"

module Fabrique

  YAML.add_domain_type("starjuice.net,2015-03-13", "beans") do |type, value|
    BeanDefinitionRegistry.new(value)
  end

  YAML.add_domain_type("starjuice.net,2015-03-13", "bean") do |type, value|
    BeanDefinition.new(value)
  end

  YAML.add_domain_type("starjuice.net,2015-03-13", "bean/ref") do |type, value|
    BeanReference.new(value)
  end

  YAML.add_domain_type("starjuice.net,2015-03-13", "bean/property_ref") do |type, value|
    BeanPropertyReference.new(value)
  end

  class YamlBeanFactory < BeanFactory

    def initialize(path_or_string)
      super bean_definition_registry beans_node load_yaml path_or_string
    end

    private

    def load_yaml(path_or_string)
      if path_or_string.is_a?(String) and path_or_string =~ /\A---\r?\n/
        YAML.load(path_or_string)
      else
        YAML.load_file(path_or_string)
      end
    end

    def beans_node(parsed_yaml)
      if parsed_yaml.respond_to?(:keys) and parsed_yaml["beans"]
        parsed_yaml["beans"]
      else
        raise "YAML contains no top-level beans node"
      end
    end

    def bean_definition_registry(beans)
      if beans.is_a?(BeanDefinitionRegistry)
        beans
      elsif beans.is_a?(Array)
        BeanDefinitionRegistry.new(beans)
      else
        raise "YAML top-level beans node must be an Array or a #{BeanDefinitionRegistry}"
      end
    end

  end

end
