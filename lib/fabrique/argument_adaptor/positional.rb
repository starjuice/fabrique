module Fabrique

  module ArgumentAdaptor

    # TODO Initialize with the name of the class we're adapting arguments for, for use in error messages
    class Positional

      def initialize(*argument_specifiers)
        @positional_arguments = argument_specifiers.map { |spec| PositionalArgument.create(spec) }
      end

      def adapt(properties = {})
        @positional_arguments.map { |argument| argument.pick(properties) }
      end

      class PositionalArgument

        class Required
          def initialize(arg)
            @arg = arg
          end

          def pick(properties)
            pick_or_do(properties) do
              raise ArgumentError, "required argument #{@arg} missing from properties"
            end
          end

          private

          def pick_or_do(properties, &block)
            if properties.include?(@arg)
              properties[@arg]
            else
              block.call
            end
          end
        end

        class Optional < Required
          def pick(properties)
            pick_or_do(properties) do
              raise ArgumentError, "optional argument #{@arg} (with no default) missing from properties"
            end
          end
        end

        class Default < Required
          def initialize(arg, default)
            @arg, @default = arg, default
          end

          def pick(properties)
            pick_or_do(properties) { @default }
          end
        end

        def self.create(specifier)
          if specifier.is_a?(Symbol)
            Required.new(specifier)
          elsif specifier.is_a?(Array) and specifier.size == 1 and specifier[0].is_a?(Symbol)
            Optional.new(*specifier)
          elsif specifier.is_a?(Array) and specifier.size == 2 and specifier[0].is_a?(Symbol)
            Default.new(*specifier)
          else
            raise ArgumentError.new("invalid argument specifier #{specifier}")
          end
        end

      end

    end

  end

end
