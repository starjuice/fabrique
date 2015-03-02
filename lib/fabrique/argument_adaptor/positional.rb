module Fabrique

  module ArgumentAdaptor

    # TODO Initialize with the name of the class we're adapting arguments for, for use in error messages
    class Positional

      def initialize(*argument_specifiers)
        validate_argument_specifiers!(argument_specifiers)
        @argument_specifiers = argument_specifiers
      end

      def adapt(properties = {})
        @argument_specifiers.inject([]) do |arguments, specifier|
          if specifier.is_a?(Array)
            arguments << adapt_optional_argument(properties, specifier)
          else
            arguments << adapt_required_argument(properties, specifier)
          end
        end
      end

      private

        def validate_argument_specifiers!(specifiers)
          specifiers.each do |specifier|
            specifier.is_a?(Symbol) or
              specifier.is_a?(Array) && (specifier.size == 1 || specifier.size == 2) && specifier[0].is_a?(Symbol) or
              raise ArgumentError.new("invalid argument specifier #{specifier}")
          end
        end

        def adapt_optional_argument(properties, specifier)
          arg, default = specifier
          if properties.include?(arg)
            properties[arg]
          elsif !default.nil?
            default
          else
            raise ArgumentError, "optional argument #{arg} (with no default) missing from properties"
          end
        end

        def adapt_required_argument(properties, specifier)
          arg = specifier
          if properties.include?(arg)
            properties[arg]
          else
            raise ArgumentError, "required argument #{arg} missing from properties"
          end
        end

    end

  end

end
