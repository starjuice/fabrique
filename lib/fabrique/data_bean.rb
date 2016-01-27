# TODO underscore method names to reduce collision

module Fabrique

  class DataBean < BasicObject

    def initialize(hash, name = nil)
      @hash = hash
      @name = name
    end

    def method_missing(sym, *args)
      key = include?(sym)

      raise_no_method_error(sym) if key.nil?
      raise_argument_error(args) unless args.empty?

      glide(sym, fetch(sym))
    end

    alias_method :send, :method_missing

    def to_s
      @name or ::Kernel.sprintf("0x%014x", __id__)
    end

    private

    def glide(sym, v)
      v.is_a?(::Hash) ? ::Fabrique::DataBean.new(v, "#{to_s}.#{sym}") : v
    end

    # TODO investigate possible optimization with Ruby 2.3 frozen strings
    def fetch(sym)
      if @hash.include?(sym)
        @hash[sym]
      elsif @hash.include?(sym.to_s)
        @hash[sym.to_s]
      else
        raise_no_method_error(sym)
      end
    end

    def include?(sym)
      if @hash.include?(sym)
        sym
      elsif @hash.include?(sym.to_s)
        sym.to_s
      end
    end

    def raise_no_method_error(sym)
      ::Kernel.raise ::NoMethodError.new("undefined method `#{sym}' for #<Fabrique::DataBean:#{to_s}>")
    end

    def raise_argument_error(args)
      ::Kernel.raise ::ArgumentError.new("wrong number of arguments (given #{args.size}, expected 0)")
    end

  end

end
