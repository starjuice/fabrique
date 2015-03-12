module Fabrique

  module Test

    module Fixtures

      module OpenGL

        class Object

          attr_reader :shader, :mesh, :scale

          def initialize(shader, physical = {})
            @shader = shader
            @mesh = physical[:mesh]
            @scale = physical[:scale]
          end

        end

        class Mesh

          attr_reader :vectors

          def initialize(vectors = [])
            @vectors = vectors
          end

        end

      end

    end

  end

end
