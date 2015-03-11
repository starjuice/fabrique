@bean_factory
Feature: Bean Factory

  As a developer
  I want injectable dependencies to be a configuration concern
  So that I can configure different dependencies in different environments.

  Scenario: Simple object with default constructor

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "default size"
    And the bean has "color" set to "default color"
    And the bean has "shape" set to "default shape"

  Scenario: Simple object with positional argument constructor

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
          constructor_args:
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

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
          constructor_args:
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

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPropertiesHashConstructor
          constructor_args:
            size: tiny
            color: purple
            shape: elephant
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "tiny"
    And the bean has "color" set to "purple"
    And the bean has "shape" set to "elephant"

  Scenario: Module by identity

    Given I have a YAML application context definition:
      """
      ---
      beans:
        my_module:
          class: Fabrique::Test::Fixtures::Modules::ModuleWithStaticMethods
          factory_method: itself
      """
    When I request a bean factory for the application context
    And I request the "my_module" bean from the bean factory
    Then the bean has "size" set to "module size"
    And the bean has "color" set to "module color"
    And the bean has "shape" set to "module shape"

  Scenario: Bean reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
        parent:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
          constructor_args:
            - small
            - red
            - {bean: child}
        child:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
          constructor_args:
            size: squished
            color: brown
            shape: poop
      """
    When I request a bean factory for the application context
    And I request the "parent" bean from the bean factory
    Then the "parent" bean has "shape" set to the "child" bean
    And the "child" bean has "shape" set to "poop"

  Scenario: Cyclic bean property reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
        left:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
          properties:
            shape: {bean: right}
        right:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
          properties:
            shape: {bean: left}
      """
    When I request a bean factory for the application context
    And I request the "left" bean from the bean factory
    Then the "left" bean has "shape" set to the "right" bean
    And the "right" bean has "shape" set to the "left" bean

  Scenario: Cyclic bean constructor arg reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
        left:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
          constructor_args:
            - {bean: right}
            - red
            - dot
        right:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
          constructor_args:
            - {bean: left}
            - purple
            - elephant
      """
    When I request a bean factory for the application context
    Then I get a cyclic bean reference error when I request the "left" bean from the bean factory
    And I get a cyclic bean reference error when I request the "right" bean from the bean factory

  Scenario: Cyclic bean property reference with non-cyclic constructor arg reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
        left:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
          properties:
            shape: {bean: right}
        right:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
          constructor_args:
            shape: {bean: left}
      """
    When I request a bean factory for the application context
    And I request the "left" bean from the bean factory
    Then the "left" bean has "shape" set to the "right" bean
    And the "right" bean has "shape" set to the "left" bean

  Scenario: Singleton bean (default

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          scope: singleton
          class: Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then I get the same object when I request the "simple_object" bean again

  Scenario: Prototype bean

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          scope: prototype
          class: Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then I get a different object when I request the "simple_object" bean again

  Scenario: Setter injection

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
          properties:
            size: large
            color: blue
            shape: square
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "large"
    And the bean has "color" set to "blue"
    And the bean has "shape" set to "square"

  Scenario: Constructor argument type

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
          constructor_args:
            - infinite
            - invisible
            - {type: Integer, value: "42"}
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "infinite"
    And the bean has "color" set to "invisible"
    And the bean has "shape" that is the Integer "42"

  Scenario: Property argument type

    Given I have a YAML application context definition:
      """
      ---
      beans:
        simple_object:
          class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
          properties:
            size: infinite
            color: invisible
            shape: {type: Integer, value: "42"}
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "infinite"
    And the bean has "color" set to "invisible"
    And the bean has "shape" that is the Integer "42"

