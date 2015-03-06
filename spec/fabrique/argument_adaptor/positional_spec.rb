require "spec_helper"

describe Fabrique::ArgumentAdaptor::Positional do

  describe "::new(*argument_specifieres)" do

    it "takes symbols as required argument names" do
      expect { described_class.new(:arg_name1, :arg_name2, :arg_name3) }.to_not raise_error
    end

    it "takes one-element arrays as optional argument names with no default value" do
      expect { described_class.new(:arg_name1, :arg_name2, [:arg_name3]) }.to_not raise_error
    end

    it "takes two-element arrays as optional argument names with a default value" do
      expect { described_class.new(:arg_name1, [:arg_name2], [:arg_name3, "default arg3"]) }.to_not raise_error
    end

    it "allows no argument names (useful for a default constructor)" do
      expect { described_class.new }.to_not raise_error
    end

    context "when passed arguments that are not symbols or optional argument specifier arrays" do

      it "raises an ArgumentError" do
        expect { described_class.new(:arg_name1, "arg_name2") }.to raise_error(ArgumentError, /invalid argument specifier/)
        expect { described_class.new(:arg_name1, []) }.to raise_error(ArgumentError, /invalid argument specifier/)
        expect { described_class.new(:arg_name1, ["arg_name2"]) }.to raise_error(ArgumentError, /invalid argument specifier/)
        expect { described_class.new(:arg_name1, [:arg_name2, "value", "nonsense"]) }.to raise_error(ArgumentError, /invalid argument specifier/)
      end

    end

  end

  describe "#adapt(*properties)" do

    context "when initialized with no required argument specifiers" do
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

    context "when initialized with optional argument names with no default values, followed by required argument names" do
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

    context "when initialized with optional argument names with nil as the default value, followed by required argument names" do
      subject { described_class.new([:size, nil], [:color, nil], :shape) }

      context "when called with a property for each argument name" do
        it "returns an array of the property value of each argument name in the order specified to new()" do
          expect(subject.adapt(shape: "dot", size: "small", color: "red")).to eql ["small", "red", "dot"]
        end
      end

      context "when called with at least one property missing for an optional argument" do
        it "returns an array of the provided property values and default values, in the order specified to new()" do
          expect(subject.adapt(color: "red", shape: "dot")).to eql [nil, "red", "dot"]
        end
      end

      context "when called with at least one property missing for a required argument" do
        it "raises an ArgumentError" do
          expect { subject.adapt(size: "small", color: "red") }.to raise_error(ArgumentError, /required argument \w+ missing from properties/)
        end
      end
    end

    it "supports default constructors" do
      klass = Fabrique::Test::Fixtures::Constructors::ClassWithDefaultConstructor
      object = klass.new(*subject.adapt())
      expect(object.size).to eql klass::DEFAULT_SIZE
      expect(object.color).to eql klass::DEFAULT_COLOR
      expect(object.shape).to eql klass::DEFAULT_SHAPE
    end

    it "supports positional argument constructors" do
      klass = Fabrique::Test::Fixtures::Constructors::ClassWithPositionalArgumentConstructor
      subject = described_class.new(:size, :color, :shape)
      object = klass.new(*subject.adapt(size: "small", color: "red", shape: "dot"))
      expect(object.size).to eql "small"
      expect(object.color).to eql "red"
      expect(object.shape).to eql "dot"
    end

  end

end
