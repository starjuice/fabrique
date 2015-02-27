require "spec_helper"

class PropertiesHashFixture
  attr_reader :color, :shape, :size

  DEFAULT_ATTRS = {color: "red", shape: "dot", size: "small"} unless defined?(DEFAULT_ATTRS)

  def initialize(properties = DEFAULT_ATTRS)
    @color, @shape, @size = properties[:color], properties[:shape], properties[:size]
  end

  def attrs
    {color: @color, shape: @shape, size: @size}
  end

end

describe Fabrique::Construction::PropertiesHash do

  describe "call(type, properties = nil)" do

    let(:type) { PropertiesHashFixture }

    it "calls type.new() if properties is not provided" do
      o = subject.call(type)
      expect(o.attrs).to eql type::DEFAULT_ATTRS
    end

    it "calls type.new(properties) if properties is provided" do
      o = subject.call(type, properties = {color: "green", shape: "patch", size: "large"})
      expect(o.attrs).to eql properties
    end

  end

end
