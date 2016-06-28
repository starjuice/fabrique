@bean_factory
Feature: Pure data definition

  As a developer
  I want to use plain data to configure a bean factory
  So that I can take bean definitions from plain configuration data

  Scenario: Factory method with bean reference as class

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: factory
        class: Fabrique::Test::Fixtures::Constructors::FactoryWithCreateMethod
      - id: created_object
        class: {"!bean/ref": factory}
        factory_method: create
      """
    When I request a bean factory for the plain data application context
    And I request the "created_object" bean from the bean factory
    Then the bean has "size" set to "factory size"
    And the bean has "color" set to "factory color"
    And the bean has "shape" set to "factory shape"

  Scenario: Bean reference

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: customer_repository
        class: Fabrique::Test::Fixtures::Repository::CustomerRepository
        constructor_args:
          - {"!bean/ref": store}
          - {"!bean/ref": customer_data_mapper}
      - id: product_repository
        class: Fabrique::Test::Fixtures::Repository::ProductRepository
        constructor_args:
          store: {"!bean/ref": store}
          data_mapper: {"!bean/ref": product_data_mapper}
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
      """
    When I request a bean factory for the plain data application context
    Then the "customer_repository" and "product_repository" beans share the same "store"
    And the "customer_repository" and "product_repository" beans each have their own "data_mapper"

  Scenario: Cyclic bean property reference

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: {"!bean/ref": right}
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: {"!bean/ref": left}
      """
    When I request a bean factory for the plain data application context
    Then I get a cyclic bean dependency error

  Scenario: Cyclic bean constructor arg reference

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - {"!bean/ref": right}
          - red
          - dot
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - {"!bean/ref": left}
          - purple
          - elephant
      """
    When I request a bean factory for the plain data application context
    Then I get a cyclic bean dependency error

  Scenario: Inner bean

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: outer
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - large
          - red
          - "!bean":
              class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
              constructor_args:
                - infinite
                - invisible
                - elephant
      """
    When I request a bean factory for the plain data application context
    And I request the "outer" bean from the bean factory
    Then the bean's "shape" is an object with "shape" set to "elephant"

  Scenario: Bean property reference

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - {"!bean/property_ref": right.size}
          - {"!bean/property_ref": right.color}
          - {"!bean/property_ref": right.shape}
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - tiny
          - purple
          - elephant
      """
    When I request a bean factory for the plain data application context
    And I request the "left" bean from the bean factory
    Then the bean has "size" set to "tiny"
    And the bean has "color" set to "purple"
    And the bean has "shape" set to "elephant"

  Scenario: Nested bean property reference

    Given I have a plain data application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - {"!bean/property_ref": middle.object.size}
          - {"!bean/property_ref": middle.object.color}
          - {"!bean/property_ref": middle.object.shape}
      - id: middle
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          object: {"!bean/ref": right}
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - tiny
          - purple
          - elephant
      """
    When I request a bean factory for the plain data application context
    And I request the "left" bean from the bean factory
    Then the bean has "size" set to "tiny"
    And the bean has "color" set to "purple"
    And the bean has "shape" set to "elephant"

