module Fabrique

  module Test

    module Fixtures

      module Modules

        module ModuleWithStaticMethods

          DEFAULT_SIZE = "module size" unless defined?(DEFAULT_SIZE)
          DEFAULT_COLOR = "module color" unless defined?(DEFAULT_COLOR)
          DEFAULT_SHAPE = "module shape" unless defined?(DEFAULT_SHAPE)

          def self.size
            DEFAULT_SIZE
          end

          def self.color
            DEFAULT_COLOR
          end

          def self.shape
            DEFAULT_SHAPE
          end

        end

      end

    end

  end

end
