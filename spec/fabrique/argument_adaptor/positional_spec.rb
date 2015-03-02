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

    context "when initialized with only optional argument names with default values" do
      subject { described_class.new([:size, "default size"], [:color, "default color"], [:shape, "default shape"]) }

      context "when called with a property for each argument name" do
        it "returns an array of the property value of each argument name in the order specified to new()" do
          expect(subject.adapt(shape: "dot", size: "small", color: "red")).to eql ["small", "red", "dot"]
        end
      end

      context "when called with at least one property missing for an argument name" do
        it "returns an array of the provided property values and default values, in the order specified to new()" do
          expect(subject.adapt(size: "small", color: "red")).to eql ["small", "red", "default shape"]
        end
      end

      context "when called with extraneous properties" do
        it "ignores them" do
          expect(subject.adapt(size: "small", color: "red", status: "on")).to eql ["small", "red", "default shape"]
        end
      end

    end

    context "when initialized with initial optional argument names with no default followed by required argument names" do
      subject { described_class.new([:size], [:color], :shape) }

      context "when called with a property for each argument name" do
        it "returns an array of the property value of each argument name in the order specified to new()" do
          expect(subject.adapt(shape: "dot", size: "small", color: "red")).to eql ["small", "red", "dot"]
        end
      end

      context "when called with at least one property missing for an optional argument" do
        it "raises an ArgumentError (because the caller would be surprised by Ruby filling optional arguments from left to right)" do
          expect {subject.adapt(color: "red", shape: "dot") }.to raise_error(ArgumentError, /optional argument size \(with no default\) missing from properties/)
        end
      end

      context "when called with at least one property missing for a required argument" do
        it "raises an ArgumentError" do
          expect { subject.adapt(size: "small", color: "red") }.to raise_error(ArgumentError, /required argument \w+ missing from properties/)
        end
      end
    end

  end

end
