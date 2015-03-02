module Fabrique

  module Construction

    class BuilderMethod

      def initialize(builder_method_name, &block)
        @builder_method_name, @builder_runner = builder_method_name, block
      end

      def call(type, properties = {})
        type.send(@builder_method_name) do |builder|
          @builder_runner.call(builder, properties)
        end
      end

    end

  end

end
