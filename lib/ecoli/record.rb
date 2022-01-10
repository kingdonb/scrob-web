# typed: strict
require 'forwardable'

module Ecoli
  class Record
    extend Forwardable
    def_delegators :@properties, :[], :[]=

    def initialize(record)
      @properties = {
        record: record,
      }
      record_keys = record.keys

      unknown_keys = (record_keys - known_keys)

      unless unknown_keys.empty?
        raise StandardError, "Record had keys we were not prepared for: #{unknown_keys}"
      end
    end

    def record
      self[:record]
    end
    
    def known_keys
      [
        :site,
        :date,
        :time,
        :ecoli,
        :do,
        :contact_tank_do,
        :outfall_do,
        :tss,
        :temp_f,
        :temp_c,
        :rain,
        :weather,
      ]
    end

    def to_csv
      known_keys.map do |k|
        v = record[k]
        if v.nil?
          ''
        else
          record[k]
        end
      end
    end
  end
end
