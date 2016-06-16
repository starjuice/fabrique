Dir[File.join(File.dirname(__FILE__), "fabrique", "*.rb")].each { |f| require_relative f }

module Fabrique
end
