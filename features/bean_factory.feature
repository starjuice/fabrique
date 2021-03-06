@bean_factory
Feature: Bean Factory

  As a developer
  I want injectable dependencies to be a configuration concern
  So that I can configure different dependencies in different environments.

  Scenario: Simple object with default constructor

    Given I have a YAML application context definition:
      """
      ---
      beans: !beans
      - !bean
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
      beans:
      - id: simple_object
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
      - id: simple_object
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
      - id: simple_object
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

  Scenario: Factory method with bean reference as class

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: factory
        class: Fabrique::Test::Fixtures::Constructors::FactoryWithCreateMethod
      - id: created_object
        class: !bean/ref factory
        factory_method: create
      """
    When I request a bean factory for the application context
    And I request the "created_object" bean from the bean factory
    Then the bean has "size" set to "factory size"
    And the bean has "color" set to "factory color"
    And the bean has "shape" set to "factory shape"

  Scenario: Module by identity

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: my_module
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
      """
    When I request a bean factory for the application context
    Then the "customer_repository" and "product_repository" beans share the same "store"
    And the "customer_repository" and "product_repository" beans each have their own "data_mapper"

  Scenario: Cyclic bean property reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: !bean/ref right
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: !bean/ref left
      """
    When I request a bean factory for the application context
    Then I get a cyclic bean dependency error

  Scenario: Cyclic bean constructor arg reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - !bean/ref right
          - red
          - dot
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - !bean/ref left
          - purple
          - elephant
      """
    When I request a bean factory for the application context
    Then I get a cyclic bean dependency error

  Scenario: Cyclic bean property reference with non-cyclic constructor arg reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
        constructor_args:
          shape: !bean/ref middle
      - id: middle
        class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
        constructor_args:
          shape: !bean/ref right
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          shape: !bean/ref left
      """
    When I request a bean factory for the application context
    Then I get a cyclic bean dependency error

  Scenario: Cyclic bean class reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: factory
        class: Fabrique::Test::Fixtures::Constructors::FactoryWithCreateMethod
        constructor_args:
          - !bean/ref created_object
      - id: created_object
        class: !bean/ref factory
        factory_method: create
      """
    When I request a bean factory for the application context
    Then I get a cyclic bean dependency error

  Scenario: Nested bean references

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: disco_cube
        class: Fabrique::Test::Fixtures::OpenGL::Object
        constructor_args:
          - glittering
          - :mesh: !bean/ref cube_mesh
            :scale: 10
      - id: cube_mesh
        class: Fabrique::Test::Fixtures::OpenGL::Mesh
        constructor_args:
          - [[0, 0, 0],[1, 0, 0],[1, 0, 1],[0, 0, 1],[0, 1, 0],[1, 1, 0],[1, 1, 1],[0, 1, 1]]
      """
    When I request a bean factory for the application context
    And I request the "disco_cube" bean from the bean factory
    Then the "disco_cube" bean has "mesh" set to the "cube_mesh" bean
    And the "disco_cube" bean has "scale" that is the Integer 10

  Scenario: Inner bean

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: outer
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - large
          - red
          - !bean
            class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
            constructor_args:
              - infinite
              - invisible
              - elephant
      """
    When I request a bean factory for the application context
    And I request the "outer" bean from the bean factory
    Then the bean's "shape" is an object with "shape" set to "elephant"

  Scenario: Bean property reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - !bean/property_ref right.size
          - !bean/property_ref right.color
          - !bean/property_ref right.shape
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - tiny
          - purple
          - elephant
      """
    When I request a bean factory for the application context
    And I request the "left" bean from the bean factory
    Then the bean has "size" set to "tiny"
    And the bean has "color" set to "purple"
    And the bean has "shape" set to "elephant"

  Scenario: Nested bean property reference

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: left
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - !bean/property_ref middle.object.size
          - !bean/property_ref middle.object.color
          - !bean/property_ref middle.object.shape
      - id: middle
        class: Fabrique::Test::Fixtures::Constructors::ClassWithProperties
        properties:
          object: !bean/ref right
      - id: right
        class: Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
        constructor_args:
          - tiny
          - purple
          - elephant
      """
    When I request a bean factory for the application context
    And I request the "left" bean from the bean factory
    Then the bean has "size" set to "tiny"
    And the bean has "color" set to "purple"
    And the bean has "shape" set to "elephant"

  Scenario: Singleton bean (default)

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: simple_object
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
      - id: simple_object
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
      - id: simple_object
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
      - id: simple_object
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
      beans:
      - id: simple_object
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

  Scenario: Data bean

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: data
        class: Fabrique::DataBean
        constructor_args:
        - size: small
          color: red
          shape: dot
      """
    When I request a bean factory for the application context
    And I request the "data" bean from the bean factory
    Then the bean has "size" set to "small"
    And the bean has "color" set to "red"
    And the bean has "shape" set to "dot"

  Scenario: Gem loader

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: sample
        class: Sample
        gem:
          name: sample
          version: "= 0.1.1"
          require: sample
        factory_method: itself
      """
    And the "sample" gem is not installed
    When I request a bean factory for the application context
    And I request that bean dependency gems be loaded for the bean factory
    And I request the "sample" bean from the bean factory
    Then the bean has "version" set to "0.1.1"

  Scenario: Gem loader with already-installed gem

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: local_only
        class: LocalOnly
        gem:
          name: local_only
          version: "= 0.1.0"
          require: local_only
        factory_method: itself
      """
    And the "local_only" gem is already installed
    When I request a bean factory for the application context
    And I request that bean dependency gems be loaded for the bean factory
    And I request the "local_only" bean from the bean factory
    Then the bean has "version" set to "0.1.0"

  Scenario: Gem loader with duplicate gem

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: sampler
        class: Fabrique::DataBean
        constructor_args:
        - sample1_version: !bean/property_ref sample1.version
          sample2_version: !bean/property_ref sample2.version
      - id: sample1
        class: Sample
        gem:
          name: sample
          version: "= 0.1.1"
          require: sample
        factory_method: itself
      - id: sample2
        class: Sample
        gem:
          name: sample
          require: sample
        factory_method: itself
      """
    And the "sample" gem is not installed
    When I request a bean factory for the application context
    And I request that bean dependency gems be loaded for the bean factory
    And I request the "sampler" bean from the bean factory
    Then the bean has "sample1_version" set to "0.1.1"
    And the bean has "sample2_version" set to "0.1.1"

  Scenario: Gem loader version conflict

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: sample
        class: Sample
        gem:
          name: sample
          version: "= 0.1.1"
          require: sample
        factory_method: itself
      - id: conflicting_sample
        class: Sample
        gem:
          name: sample
          version: "= 0.1.0"
          require: sample
        factory_method: itself
      """
    And the "sample" gem is not installed
    When I request a bean factory for the application context
    And I request that bean dependency gems be loaded for the bean factory
    Then I get a gem dependency error

  Scenario: Gem loader install error

    Given I have a YAML application context definition:
      """
      ---
      beans:
      - id: sample
        class: Sample
        gem:
          name: nosuchgeminstallable
        factory_method: itself
      """
    And the "sample" gem is not installed
    When I request a bean factory for the application context
    And I request that bean dependency gems be loaded for the bean factory
    Then I get a gem dependency error

  Scenario: #to_h

    Given I have a YAML application context definition:
      """
      ---
      beans: !beans
      - !bean
        id: square_bean
        class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
        constructor_args:
          shape: square
      - !bean
        id: round_bean
        class: Fabrique::Test::Fixtures::Constructors::ClassWithKeywordArgumentConstructor
        constructor_args:
          shape: round
      """
    When I request a bean factory for the application context
    And I request a dictionary of all beans
    Then the dictionary maps "square_bean" to the "square_bean" bean
    And the dictionary maps "round_bean" to the "round_bean" bean

