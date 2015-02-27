module Fabrique

  module Construction

    class PositionalArgument

      def initialize(*argument_names)
        @argument_names = argument_names
      end

      def call(type, properties = nil)
        if properties.nil?
          type.new
        else
          type.new(*get_args(properties))
        end
      end

      private

        def get_args(properties)
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
