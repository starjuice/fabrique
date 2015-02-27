require "spec_helper"

describe Fabrique::ArgumentAdaptor::Positional do

  describe "#adapt(*properties)" do

    context "when initialized with no required argument names" do
      context "when called without properties" do
        it "returns an empty array" do
          expect(subject.adapt).to eql []
        end
      end

      context "when called with empty properties" do
        it "returns an empty array" do
          expect(subject.adapt({})).to eql []
        end
      end

      context "when called with properties" do
        it "returns an empty array" do
          expect(subject.adapt(size: "small", color: "red", shape: "dot")).to eql []
        end
      end
    end

    context "when initialized with only required argument names" do
      subject { described_class.new(:size, :color, :shape) }

      context "when called with a property for each argument name" do
        it "returns an array of the property value of each argument name in the order specified to new()" do
          expect(subject.adapt(shape: "dot", size: "small", color: "red")).to eql ["small", "red", "dot"]
        end
      end

      context "when called with at least one property missing for an argument name" do
        it "raises an ArgumentError" do
          expect { subject.adapt(size: "small", color: "red") }.to raise_error(ArgumentError, /required argument \w+ missing from properties/)
        end
      end

      context "when called with extraneous properties" do
        it "ignores them, returning an array of the property value of each argument name in the order specified to new()" do
          expect(subject.adapt(size: "small", color: "red", shape: "dot", status: "on")).to eql ["small", "red", "dot"]
        end
      end
    end

    context "when initialized with only optional argument names" do
      subject { described_class.new([:size, :color, :shape]) }

      context "when called with a property for each argument name" do
        it "returns an array of the property value of each argument name in the order specified to new()" do
          expect(subject.adapt(shape: "dot", size: "small", color: "red")).to eql ["small", "red", "dot"]
        end
      end

      context "when called with at least one property missing for an argument name" do
        it "returns an array of the provided property values in the order specified to new()" do
          expect(subject.adapt(size: "small", color: "red")).to eql ["small", "red"]
        end
      end

      context "when called with extraneous properties" do
        it "ignores them, returning an array of the provided property values for each argument name in the order specified to new()" do
          expect(subject.adapt(size: "small", color: "red", status: "on")).to eql ["small", "red"]
        end
      end

    end

    context "when initialized with initial optional argument names followed by required argument names" do
      subject { described_class.new([:size, :color], :shape) }

      context "when called with at least one property missing for an argument name" do
        it "it fills the optional arguments from left to right, probably surprising the developer" do
          expect(subject.adapt(color: "red", shape: "dot")).to eql ["red", "dot"]

          # So far so good, but...
          # Ruby fills required arguments first, then optional arguments from left to right.
          # So...
          #
          pending("this feature is too surprising")

          class Surprise
            def initialize(size = nil, color = nil, shape)
              @size, @color, @shape = size, color, shape
            end
            attr_reader :size, :color, :shape
          end
          surprise = Surprise.new("red", "dot")
          expect(surprise.size).to eql "red"
          expect(surprise.color).to be nil
          expect(surprise.shape).to eql "dot"

          # Were you surprised? I was surprised.

          expect(@developer_happiness).to eql "high"

          # Possible solutions:
          # * Don't allow initial optional arguments: fail fast, in ::new()
          # * Require all or none of initial optional arguments to be supplied: fail late, in #adapt()
        end
      end
    end

  end

end
