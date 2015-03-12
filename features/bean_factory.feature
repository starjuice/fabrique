@bean_factory
Feature: Bean Factory

  As a developer
  I want injectable dependencies to be a configuration concern
  So that I can configure different dependencies in different environments.

  Scenario: Simple object with default constructor

    Given I have a YAML application context definition:
      """
      ---
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: my_module
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
      !!beans
      - !!bean
        id: customer_repository
        class: Fabrique::Test::Fixtures::Repository::CustomerRepository
        constructor_args:
          - !!bean/ref store
          - !!bean/ref customer_data_mapper
      - !!bean
        id: product_repository
        class: Fabrique::Test::Fixtures::Repository::ProductRepository
        constructor_args:
          store: !!bean/ref store
          data_mapper: !!bean/ref product_data_mapper
      - !!bean
        id: store
        class: Fabrique::Test::Fixtures::Repository::MysqlStore
        constructor_args:
          host: localhost
          port: 3306
      - !!bean
        id: customer_data_mapper
        class: Fabrique::Test::Fixtures::Repository::CustomerDataMapper
        scope: prototype
      - !!bean
        id: product_data_mapper
        class: Fabrique::Test::Fixtures::Repository::ProductDataMapper
        scope: prototype
      """
    When I request a bean factory for the application context
    Then the "customer_repository" and "product_repository" beans share the same "store"
    And the "customer_repository" and "product_repository" beans each have their own "data_mapper"

  Scenario: Cyclic bean property reference

    Given I have a YAML application context definition:
      """
      ---
      !!beans
      - !!bean
        id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: !!bean/ref right
      - !!bean
        id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: !!bean/ref left
      """
    Then I get a cyclic bean dependency error when I request a bean factory for the application context

  Scenario: Cyclic bean constructor arg reference

    Given I have a YAML application context definition:
      """
      ---
      !!beans
      - !!bean
        id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - !!bean/ref right
          - red
          - dot
      - !!bean
        id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - !!bean/ref left
          - purple
          - elephant
      """
    Then I get a cyclic bean dependency error when I request a bean factory for the application context

  Scenario: Cyclic bean property reference with non-cyclic constructor arg reference

    Given I have a YAML application context definition:
      """
      ---
      !!beans
      - !!bean
        id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
        constructor_args:
          shape: !!bean/ref middle
      - !!bean
        id: middle
        class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
        constructor_args:
          shape: !!bean/ref right
      - !!bean
        id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: !!bean/ref left
      """
    Then I get a cyclic bean dependency error when I request a bean factory for the application context

  Scenario: Nested bean references

    Given I have a YAML application context definition:
      """
      ---
      !!beans
      - !!bean
        id: disco_cube
        class: Fabrique::Test::Fixtures::OpenGL::Object
        constructor_args:
          - glittering
          - :mesh: !!bean/ref cube_mesh
            :scale: 10
      - !!bean
        id: cube_mesh
        class: Fabrique::Test::Fixtures::OpenGL::Mesh
        constructor_args:
          - [[0, 0, 0],[1, 0, 0],[1, 0, 1],[0, 0, 1],[0, 1, 0],[1, 1, 0],[1, 1, 1],[0, 1, 1]]
      """
    When I request a bean factory for the application context
    And I request the "disco_cube" bean from the bean factory
    Then the "disco_cube" bean has "mesh" set to the "cube_mesh" bean
    And the "disco_cube" bean has "scale" that is the Integer 10

  Scenario: Singleton bean (default)

    Given I have a YAML application context definition:
      """
      ---
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: simple_object
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
      !!beans
      - !!bean
        id: simple_object
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - infinite
          - invisible
          - 42
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
      !!beans
      - !!bean
        id: simple_object
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          size: infinite
          color: invisible
          shape: 42
      """
    When I request a bean factory for the application context
    And I request the "simple_object" bean from the bean factory
    Then the bean has "size" set to "infinite"
    And the bean has "color" set to "invisible"
    And the bean has "shape" that is the Integer "42"

