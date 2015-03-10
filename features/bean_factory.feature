@bean_factory
Feature: Bean Factory

  As a developer
  I want injectable dependencies to be a configuration concern
  So that I can configure different dependencies in different environments.

  Scenario: Simple object with default constructor

    Given I have a YAML application context:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor
          method: constructor
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "default size"
    And the bean has "color" set to "default color"
    And the bean has "shape" set to "default shape"

  Scenario: Simple object with positional argument constructor

    Given I have a YAML application context:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
          method: constructor
          arguments:
            - small
            - red
            - dot
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "small"
    And the bean has "color" set to "red"
    And the bean has "shape" set to "dot"


  Scenario: Simple object with keyword argument constructor

    Given I have a YAML application context:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
          method: constructor
          arguments:
            size: large
            color: black
            shape: hole
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "large"
    And the bean has "color" set to "black"
    And the bean has "shape" set to "hole"


  Scenario: Simple object with hash properties constructor

    Given I have a YAML application context:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPropertiesHashConstructor
          method: constructor
          arguments:
            size: tiny
            color: purple
            shape: elephant
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "tiny"
    And the bean has "color" set to "purple"
    And the bean has "shape" set to "elephant"

