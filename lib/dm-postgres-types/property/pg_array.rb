# encoding: utf-8

require 'dm-core'

module DataMapper
  class Property
    class PgArray < Object
      def load(value)
        return [] if value.nil?
        return value if value.kind_of?(Array)
        value.gsub!(/[{}]/,'')
        CSV.parse_line(value) || []
      end

      def dump(value)
        return nil if value.nil?
        "{#{CSV.generate_line(value, row_sep: '')}}"
      end
    end
  end
end
