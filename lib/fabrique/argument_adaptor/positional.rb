module Fabrique

  module ArgumentAdaptor

    # TODO Initialize with the name of the class we're adapting arguments for, for use in error messages
    class Positional

      # TODO validate array argument specs
      def initialize(*argument_names)
        @argument_names = argument_names
      end

      def adapt(properties = {})
        @argument_names.inject([]) do |arguments, arg|
          if arg.is_a?(Array)
            arguments << adapt_optional_argument(properties, arg)
          else
            arguments << adapt_required_argument(properties, arg)
          end
        end
      end

      private

        def adapt_optional_argument(properties, argument_and_default)
          arg, default = argument_and_default
          if properties.include?(arg)
            properties[arg]
          elsif !default.nil?
            default
          else
            raise ArgumentError, "optional argument #{arg} (with no default) missing from properties"
          end
        end

        def adapt_required_argument(properties, arg)
          if properties.include?(arg)
            properties[arg]
          else
            raise ArgumentError, "required argument #{arg} missing from properties"
          end
        end

    end

  end

end
