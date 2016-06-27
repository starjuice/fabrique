module Fabrique

  class BeanDefinition
    attr_reader :constructor_args, :factory_method, :gem, :id, :properties, :type

    def initialize(attrs = {})
      @id = attrs["id"]
      # TODO refactor: push down and validate
      @type = map_values_to_references(attrs["class"])
      @gem = GemDefinition.new(attrs["gem"]) if attrs["gem"]
      @constructor_args = map_values_to_references(attrs["constructor_args"] || [])
      @constructor_args = keywordify(@constructor_args) if @constructor_args.is_a?(Hash)
      @properties = map_values_to_references(attrs["properties"] || {})
      @scope = attrs["scope"] || "singleton"
      @factory_method = attrs["factory_method"] || "new"
    end

    def dependencies
      (accumulate_dependencies(@type) + accumulate_dependencies(@constructor_args) + accumulate_dependencies(@properties)).uniq
    end

    def singleton?
      @scope == "singleton"
    end

    private

      # TODO refactor: rather just traverse the entire bean context, resolving tags like bean, bean/ref, etc in one parsing step in BeanFactory or BeanDefinitionRegistry or above
      def map_values_to_references(o)
        if o.is_a?(BeanReference)
          o
        elsif o.is_a?(Hash) and o.key?("bean/ref")
          BeanReference.new(o["bean/ref"])
        elsif o.is_a?(Hash)
          o.map { |k, v| [k, map_values_to_references(v)] }.to_h
        elsif o.is_a?(Array)
          o.map { |v| map_values_to_references(v) }
        else
          o
        end
      end

      def keywordify(args)
        args.inject({}) { |m, (k, v)| k = k.intern rescue k; m[k.intern] = v; m }
      end

      def accumulate_dependencies(data, acc = [])
        if data.is_a?(Hash)
          accumulate_dependencies(data.values, acc)
        elsif data.is_a?(Array)
          data.each do |o|
            accumulate_dependencies(o, acc)
          end
        elsif data.is_a?(BeanReference) or data.is_a?(BeanPropertyReference)
          acc << data
        end
        acc
      end

  end

end
