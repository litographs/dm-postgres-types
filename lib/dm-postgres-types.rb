# encoding: utf-8

# deps
require 'dm-core'
require 'dm-migrations'
require 'dm-types'
require 'dm-postgres-adapter'

# lib
require 'dm-postgres-types/property/pg_array'
require 'dm-postgres-types/property/pg_numeric_array'
require 'dm-postgres-types/property/pg_hstore'
require 'dm-postgres-types/property/pg_json'
require 'dm-postgres-types/version'

# migrations and primitives
module DataMapper
  module Migrations
    module PostgresAdapter
      def property_schema_hash(property)
        schema = super

        if property.kind_of?(Property::DecimalArray)
          schema[:primitive] = "#{schema[:primitive]}(#{property.precision},#{property.scale})[]"
          schema[:precision] = schema[:scale] = nil
        elsif property.kind_of?(Property::StringArray)
          schema[:primitive] = "#{schema[:primitive]}[]"
          schema[:length] = nil
        elsif property.kind_of?(Property::PgJSON)
          schema.delete(:length)
        end

        schema
      end
    end
  end

  module PostgresTypes
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def type_map
        postgres_types = { 
          Property::HStore => { primitive: 'HSTORE' },
          Property::DecimalArray => { primitive: "NUMERIC" },
          Property::StringArray => { primitive: "TEXT" },
          Property::PgJSON => { primitive: 'JSON' }
        }
        super.merge(postgres_types).freeze
      end
    end
  end
end

DataMapper::Adapters::PostgresAdapter.send(:include, DataMapper::PostgresTypes)
