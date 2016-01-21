require "rspec"
require "fabrique/test"

class PluginRegistryTestRunner
  include RSpec::Matchers
  include Fabrique::Test::Fixtures::Constructors

  def initialize(subject_constructor)
    @subject_constructor = subject_constructor
  end

  def have_plugin_registry
    @registry = @subject_constructor.call
  end

  def have_class_with_default_constructor
    @class = ClassWithDefaultConstructor
  end

  def have_two_classes_with_default_constructors
    @class1 = ClassWithDefaultConstructor
    @class2 = OtherClassWithDefaultConstructor
  end

  def have_object(object)
    @object = object
  end

  def have_class_with_positional_argument_constructor
    @class = ClassWithPositionalArgumentConstructor
  end

  def have_class_with_properties_hash_constructor
    @class = ClassWithPropertiesHashConstructor
  end

  def have_class_with_keyword_argument_constructor
    @class = ClassWithKeywordArgumentConstructor
  end

  def have_class_with_builder_method
    @class = ClassWithBuilderMethod
  end

  def register_class_with_as_is_constructor
    @identity = :my_plugin
    @registry.register(@identity, @class, Fabrique::Construction::Default.new)
  end

  def register_classes_with_default_constructors
    @identity1 = :plugin1
    @identity2 = :plugin2
    @registry.register(@identity1, @class1, Fabrique::Construction::Default.new)
    @registry.register(@identity2, @class2, Fabrique::Construction::Default.new)
  end

  def register_object_with_as_is_constructor
    @identity = :my_plugin
    @registry.register(@identity, @object, Fabrique::Construction::AsIs.new)
  end

  def register_class_with_properties_hash_constructor
    @identity = :my_plugin
    @registry.register(@identity, @class, Fabrique::Construction::PropertiesHash.new)
  end

  def register_class_with_positional_argument_constructor
    @identity = :my_plugin
    @registry.register(@identity, @class, Fabrique::Construction::PositionalArgument.new(:size, :color, :shape))
  end

  def register_class_with_keyword_argument_constructor
    @identity = :my_plugin
    @registry.register(@identity, @class, Fabrique::Construction::KeywordArgument.new)
  end

  def register_class_with_builder_method
    @identity = :my_plugin
    @registry.register(@identity, @class, Fabrique::Construction::BuilderMethod.new(:build) { |builder, properties|
      builder.size = properties[:size]
      builder.color = properties[:color]
      builder.shape = properties[:shape]
    })
  end

  def can_acquire_instances_of_class
    instance1 = @registry.acquire(@identity)
    instance2 = @registry.acquire(@identity)
    expect(instance1.class).to eql @class
    expect(instance2.class).to eql @class
    expect(instance1.object_id).to_not eql instance2.object_id
  end

  def can_acquire_instances_of_classes
    instance1 = @registry.acquire(@identity1)
    instance2 = @registry.acquire(@identity2)
    expect(instance1.class).to eql @class1
    expect(instance2.class).to eql @class2
  end

  def can_acquire_same_object_id_every_time
    instance1 = @registry.acquire(@identity)
    instance2 = @registry.acquire(@identity)
    expect(instance1.object_id).to eql @object.object_id
    expect(instance2.object_id).to eql @object.object_id
  end

  def can_acquire_instance_of_class_with_properties
    @instance = @registry.acquire(@identity, size: "large", color: "pink", shape: "cube")
  end

  def can_verify_instance_properties
    expect(@instance.color).to eql "pink"
    expect(@instance.shape).to eql "cube"
    expect(@instance.size).to eql "large"
  end

end

require "fabrique"

Before do |scenario|
  if scenario.tags.any? { |tag| tag.name == "@plugin_registry" }
    @test = PluginRegistryTestRunner.new( -> {Fabrique::PluginRegistry.new("Test plugin registry")})
  end
end

Given(/^I have a plugin registry$/) do
  @test.have_plugin_registry
end

Given(/^I have a class with a default constructor$/) do
  @test.have_class_with_default_constructor
end

Given(/^I have two classes with default constructors$/) do
  @test.have_two_classes_with_default_constructors
end

Given(/^I have an? \w+, i\.e\. (.+)$/) do |code|
  @test.have_object(eval code)
end

Given(/^I have a class with a positional argument constructor$/) do
  @test.have_class_with_positional_argument_constructor
end

Given(/^I have a class with a properties hash constructor$/) do
  @test.have_class_with_properties_hash_constructor
end

Given(/^I have a class with a keyword argument constructor$/) do
  @test.have_class_with_keyword_argument_constructor
end

Given(/^I have a class with a builder method$/) do
  @test.have_class_with_builder_method
end

When(/^I register the class into the registry with a unique identity and a default construction method$/) do
  @test.register_class_with_as_is_constructor
end

When(/^I register each class into the registry with a unique identity and a default construction method$/) do
  @test.register_classes_with_default_constructors
end

When(/^I register the \w+ into the registry with a unique identity and an as\-is construction method$/) do
  @test.register_object_with_as_is_constructor
end

When(/^I register the class into the registry with a unique identity and a properties hash construction method$/) do
  @test.register_class_with_properties_hash_constructor
end

When(/^I register the class into the registry with a unique identity and a positional argument construction method$/) do
  @test.register_class_with_positional_argument_constructor
end

When(/^I register the class into the registry with a unique identity and a keyword argument construction method$/) do
  @test.register_class_with_keyword_argument_constructor
end

When(/^I register the class into the registry with a unique identity and builder construction method$/) do
  @test.register_class_with_builder_method
end

Then(/^I can acquire instances of the class from the registry by its unique identity$/) do
  @test.can_acquire_instances_of_class
end

Then(/^I can acquire instances of each class from the registry by its unique identity$/) do
  @test.can_acquire_instances_of_classes
end

Then(/^I get the same \w+ every time I acquire the same identity$/) do
  @test.can_acquire_same_object_id_every_time
end

Then(/^I can acquire an instance of the class from the registry by its unique identity, specifying properties with a hash argument$/) do
  @test.can_acquire_instance_of_class_with_properties
end

Then(/^the instance has the specified properties$/) do
  @test.can_verify_instance_properties
end

