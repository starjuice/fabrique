module Fabrique

  module ArgumentAdaptor

    # TODO Initialize with the name of the class we're adapting arguments for, for use in error messages
    class Positional

      def initialize(*argument_names)
        @argument_names = argument_names
      end

      def adapt(properties = {})
        @argument_names.inject([]) do |arguments, arg|
          if arg.is_a?(Array)
            arg.each do |optional_arg|
              arguments << properties[optional_arg] if properties.include?(optional_arg)
            end
          elsif properties.include?(arg)
            arguments << properties[arg]
          else
            raise ArgumentError, "required argument #{arg} missing from properties"
          end
          arguments
        end
      end

    end

  end

end
