module Fabrique

  module Test

    module Fixtures

      module Constructors

        class FactoryWithCreateMethod

          def initialize(*args)
          end

          def create
            ClassWithPositionalArgumentConstructor.new("factory size", "factory color", "factory shape")
          end

        end

        class ClassWithProperties

          DEFAULT_SIZE = "default size" unless defined?(DEFAULT_SIZE)
          DEFAULT_COLOR = "default color" unless defined?(DEFAULT_COLOR)
          DEFAULT_SHAPE = "default shape" unless defined?(DEFAULT_SHAPE)

          attr_accessor :size, :color, :shape

        end

        class ClassWithDefaultConstructor < ClassWithProperties

          def initialize
            @size, @color, @shape = DEFAULT_SIZE, DEFAULT_COLOR, DEFAULT_SHAPE
          end

        end

        OtherClassWithDefaultConstructor = Class.new(ClassWithDefaultConstructor)

        class ClassWithPropertiesHashConstructor < ClassWithProperties

          def initialize(properties)
            @size, @color, @shape = properties[:size], properties[:color], properties[:shape]
          end

        end

        class ClassWithPositionalArgumentConstructor < ClassWithProperties

          def initialize(size, color, shape)
            @size, @color, @shape = size, color, shape
          end

        end

        class ClassWithKeywordArgumentConstructor < ClassWithProperties

          def initialize(size: DEFAULT_SIZE, color: DEFAULT_COLOR, shape: DEFAULT_SHAPE)
            @size, @color, @shape = size, color, shape
          end

        end

        class ClassWithBuilderMethod < ClassWithProperties

          private_class_method :new

          def initialize(builder)
            @size, @color, @shape = builder.size, builder.color, builder.shape
          end

          def self.build
            builder = Builder.new
            if block_given?
              yield builder
            end
            new(builder)
          end

          class Builder
            attr_accessor :size, :color, :shape
          end

        end

      end

    end

  end

end
