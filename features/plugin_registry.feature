@plugin_registry
Feature: Plugin registry

  As a developer
  I want to register the identity and construction method of different plugins
  So that I can decouple their dependants from their means of creation

  Plugins are classes, modules, objects or lambdas that may come from other developers, and so
  may have disparate construction methods. A plugin registry allows these differences to be
  abstracted, and for them to be created by a known and invariant identity. The identities of
  plugins must be defined by the developer of the dependant.

  This does not address the concern of ensuring that multiple plugins offer the same interface.
  That concern is dealt with by a contract conformance strategy (e.g. interface through
  delegation).

  Most developers will not use a plugin registry directly. Instead, they will use a factory
  that implements a conformance strategy. This has the additional benefit of allowing the
  developers of plugins to define and register the identities of their plugins.

  Scenario: Multiple plugins

    Given I have a plugin registry
    And I have two classes with default constructors
    When I register each class into the registry with a unique identity and a default construction method
    Then I can acquire instances of each class from the registry by its unique identity

  Scenario Outline: As-is plugin

    Given I have a plugin registry
    And I have <article> <entity>, i.e. <code>
    When I register the <entity> into the registry with a unique identity and an as-is construction method
    Then I get the same <entity> every time I acquire the same identity

    Examples:
      | article | entity | code       |
      | an      | object | Object.new |
      | a       | class  | Class      |
      | a       | module | Module     |
      | a       | lambda | -> {}      |

  Scenario: Classical plugin with default constructor

    Given I have a plugin registry
    And I have a class with a default constructor
    When I register the class into the registry with a unique identity and a default construction method
    Then I can acquire instances of the class from the registry by its unique identity

  Scenario: Classical plugin with properties hash constructor

    Given I have a plugin registry
    And I have a class with a properties hash constructor
    When I register the class into the registry with a unique identity and a properties hash construction method
    Then I can acquire an instance of the class from the registry by its unique identity, specifying properties with a hash argument

  Scenario: Classical plugin with positional argument constructor

    Given I have a plugin registry
    And I have a class with a positional argument constructor
    When I register the class into the registry with a unique identity and a positional argument construction method
    Then I can acquire an instance of the class from the registry by its unique identity, specifying properties with a hash argument
    And the instance has the specified properties

  Scenario: Classical plugin with keyword argument constructor

    Given I have a plugin registry
    And I have a class with a keyword argument constructor
    When I register the class into the registry with a unique identity and a keyword argument construction method
    Then I can acquire an instance of the class from the registry by its unique identity, specifying properties with a hash argument
    And the instance has the specified properties

  Scenario: Builder pattern plugin

    Given I have a plugin registry
    And I have a class with a builder method
    When I register the class into the registry with a unique identity and builder construction method
    Then I can acquire an instance of the class from the registry by its unique identity, specifying properties with a hash argument
    And the instance has the specified properties

