require "spec_helper"

class PositionalArgumentFixture
  attr_reader :color, :shape, :size

  DEFAULT_ATTRS = {color: "red", shape: "dot", size: "small"} unless defined?(DEFAULT_ATTRS)

  def initialize(color = DEFAULT_ATTRS[:color], shape = DEFAULT_ATTRS[:shape], size = DEFAULT_ATTRS[:size])
    @color, @shape, @size = color, shape, size
  end

  def attrs
    {color: @color, shape: @shape, size: @size}
  end

end

describe Fabrique::Construction::PositionalArgument do

  let(:type) { PositionalArgumentFixture }

  describe "call(type, properties = nil)" do

    it "applies positional argument construction to the type, in the order they were provided to new()" do
      subject = described_class.new(:color, :shape, :size)
      constructed = subject.call(type, {size: "tiny", color: "purple", shape: "dot"})
      expect(constructed.attrs).to eql({color: "purple", shape: "dot", size: "tiny"})
    end

    it "calls type.new() if no arguments were specified to new()" do
      subject = described_class.new()
      type = spy('type')
      subject.call(type, {size: "tiny", color: "purple", shape: "dot"})
      expect(type).to have_received(:new).with(no_args)
    end

    context "when one or more optional arguments were specified to new()" do

      subject = described_class.new(:color, [:shape, :size])

      it "passes optional arguments provided in properties" do
        type = spy('type')
        subject.call(type, {color: "purple", shape: "dot", size: "tiny"})
        expect(type).to have_received(:new).with("purple", "dot", "tiny")
      end

      it "discards optional arguments if they are not present in the properties" do
        type = spy('type')
        subject.call(type, {size: "tiny", color: "purple"})
        expect(type).to have_received(:new).with("purple", "tiny")
      end

      it "raises an ArgumentError if required arguments are not present in the properties" do
        expect { subject.call(Object, shape: "dot", size: "tiny") }.to raise_error(ArgumentError, /required argument color missing/)
      end

    end

  end

end
