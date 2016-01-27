# frozen_string_literal: true

require 'spec_helper'

describe Fabrique::DataBean do

  context "over a string-keyed hash" do

    let(:wrapped) do
      {
        "string" => "string value",
        "number" => 42,
        "array" => %w[element1 element2 element3].freeze,
        "hash" => {"key" => "value"}.freeze
      }.freeze
    end

    subject { described_class.new(wrapped) }

    it "provides direct method access to the values of top-level scalar keys" do
      expect(subject.string).to eql wrapped["string"]
      expect(subject.number).to eql wrapped["number"]
      expect(subject.array).to eql wrapped["array"]
    end

    it "provides daisy-chained method access to the values of nested hash keys" do
      expect(subject.hash.key).to eql wrapped["hash"]["key"]
    end

    it "raises NoMethodError for access to non-existent top-level keys" do
      expect { subject.nosuchmethod }.to raise_error(NoMethodError, /undefined method `nosuchmethod' for /)
    end

    it "raises NoMethodError for access to non-existent nested keys" do
      expect { subject.hash.nosuchnestedmethod }.to raise_error(NoMethodError, /undefined method `nosuchnestedmethod' for/)
    end

  end

  context "over a symbol-keyed hash" do

    let(:wrapped) do
      {
        string: "string value",
        number: 42,
        array: %w[element1 element2 element3].freeze,
        hash: {key: "value"}.freeze
      }.freeze
    end

    subject { described_class.new(wrapped) }

    it "provides direct method access to the values of top-level scalar keys" do
      expect(subject.string).to eql wrapped[:string]
      expect(subject.number).to eql wrapped[:number]
      expect(subject.array).to eql wrapped[:array]
    end

    it "provides daisy-chained method access to the values of nested hash keys" do
      expect(subject.hash.key).to eql wrapped[:hash][:key]
    end

    it "raises NoMethodError for access to non-existent top-level keys" do
      expect { subject.nosuchmethod }.to raise_error(NoMethodError, /undefined method `nosuchmethod' for /)
    end

    it "raises NoMethodError for access to non-existent nested keys" do
      expect { subject.hash.nosuchnestedmethod }.to raise_error(NoMethodError, /undefined method `nosuchnestedmethod' for/)
    end

  end

  context "regardless of wrapped hash" do

    let(:wrapped) do
      {
        "meaning_of_life" => 42,
        "object_id" => "The best object ever!",
        "hash" => "A breakfast food type",
        "top" => {middle: {"bottom" => {key: "value"}}}
      }
    end

    subject { described_class.new(wrapped) }

    it "goes out of its way to avoid method name collision" do
      expect(subject.object_id).to eql wrapped["object_id"]
      expect(subject.hash).to eql wrapped["hash"]
    end

    it "raises ArgumentError on known method access with arguments" do
      expect { subject.meaning_of_life(42) }.to raise_error(ArgumentError, /wrong number of arguments \(given 1, expected 0\)/)
    end

    it "raises NoMethodError on unknown method access with arguments" do
      expect { subject.nosuchmethod(42) }.to raise_error(NoMethodError, /undefined method `nosuchmethod' for /)
    end

    context "without a name" do

      subject { described_class.new(wrapped) }

      it "includes its string representation in NoMethodError messages" do
        expect { subject.nosuchmethod }.to raise_error(/ for #<#{described_class}:#{subject.to_s}>/)
      end

      it "includes its string representation and nested keys daisy-chained in NoMethodError messages" do
        expect { subject.top.middle.bottom.nosuchnestedmethod }.to raise_error(/ for #<#{described_class}:#{subject.to_s}.top.middle.bottom>/)
      end

    end

    context "with a name" do

      subject { described_class.new(wrapped, "config") }

      it "includes its name in NoMethodError messages" do
        expect { subject.nosuchmethod }.to raise_error(NoMethodError, / for #<#{described_class}:config>/)
      end

      it "includes its name and nested keys daisy-chained in NoMethodError messages" do
        expect { subject.top.middle.bottom.nosuchnestedmethod }.to raise_error(/ for #<#{described_class}:config.top.middle.bottom>/)
      end

    end

  end

end
