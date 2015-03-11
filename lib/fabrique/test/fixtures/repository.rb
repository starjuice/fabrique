module Fabrique

  module Test

    module Fixtures

      module Repository

        class Customer

          attr_reader :id, :name, :date_of_birth

          def initialize(id: nil, name: nil, date_of_birth: nil)
            @id, @name, @date_of_birth = id, name, date_of_birth
          end

        end

        class CustomerRepository

          # Exposed for testing
          attr_reader :store, :data_mapper

          def initialize(store, data_mapper)
            @store, @data_mapper = store, data_mapper
          end

          def persist(entity)
            id = @store.save(:customer, @data_mapper.to_dto(entity))
            if !id.nil?
              entity.id = id
            end
          end

          def locate(entity_id)
            @data_mapper.from_dto(@store.find(:customer, entity_id))
          end

        end

        class ProductRepository

          # Exposed for testing
          attr_reader :store, :data_mapper

          def initialize(store: nil, data_mapper: nil)
            @store, @data_mapper = store, data_mapper
          end

          def persist(entity)
            id = @store.save(:customer, @data_mapper.to_dto(entity))
            if !id.nil?
              entity.id = id
            end
          end

          def search(filter)
            @data_mapper.from_dto(@store.search(:customer, filter))
          end

        end

        class MysqlConnection

          def initialize(*args)
            # ...
          end

          def method_missing(method_sym, *arguments)
            42
          end

        end

        class MysqlStore

          def initialize(host: 'localhost', port: 3306, username: nil, password: nil)
            @connection = MysqlConnection.new(host, port, username, password)
          end

          def find(table, id)
            @connection.find(table, "WHERE customer_id = ?", [id])
          end

          def search(table, filter)
            clauses, bindings = [], []
            filter.each do |k, v|
              clauses << k
              bindings << v
            end
            @connection.select(table, clauses.join(" AND "), bindings)
          end

          def save(table, record)
            @connection.update_or_insert(table, record)
          end

        end

        require "date"
        class CustomerDataMapper

          def to_dto(entity)
            {
              id: entity.id,
              name: entity.name,
              dob: entity.date_of_birth.iso8601
            }
          end

          def from_dto(dto)
            Customer.new(id: dto[:id], name: dto[:name], date_of_birth: Date.parse(dto[:dob]))
          end

        end

        class ProductDataMapper

          def to_dto(entity)
            {
              id: entity.id,
              name: entity.name,
              price: entity.price,
            }
          end

          def from_dto(dto)
            Product.new(id: dto[:id], name: dto[:name], price: dto[:price])
          end

        end

      end

    end

  end

end
