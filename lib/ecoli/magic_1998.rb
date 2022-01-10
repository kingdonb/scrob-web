# typed: strict
require 'forwardable'

module Ecoli
  class Magic1998
    extend Forwardable
    def_delegators :@properties, :[], :[]=

    def initialize(worksheet:)
      @properties = {
        worksheet: worksheet,
      }
    end

    def worksheet
      self[:worksheet].worksheet
    end

    def sitenames_row
      worksheet.rows[0]
    end

    def sitename_1
      sitenames_row[2]
    end

    def sitename_2
      sitenames_row[6]
    end

    def sitename_3
      sitenames_row[10]
    end

    def sitename_4
      sitenames_row[14]
    end

    def header_row
      worksheet.rows[2]
    end 

    def records
      [site1_records, site2_records, site3_records, site4_records].flatten
    end

    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/98} =~ row[0]
      end
    end

    def site1_records
      data_rows.map do |row|
        {
          site: sitename_1,
          date: row[0],
          ecoli: row[1],
          do: row[2],
          tss: row[3],
          temp_f: row[4],
          rain: row[18]
        }
      end
    end

    def site2_records
      data_rows.map do |row|
        {
          site: sitename_2,
          date: row[0],
          ecoli: row[5],
          do: row[6],
          tss: row[7],
          temp_f: row[8],
          rain: row[18]
        }
      end
    end

    def site3_records
      data_rows.map do |row|
        {
          site: sitename_3,
          date: row[0],
          ecoli: row[9],
          do: row[10],
          tss: row[11],
          temp_f: row[12],
          rain: row[18]
        }
      end
    end

    def site4_records
      data_rows.map do |row|
        {
          site: sitename_4,
          date: row[0],
          ecoli: row[13],
          contact_tank_do: row[14],
          outfall_do: row[15],
          tss: row[16],
          temp_f: row[17],
          rain: row[18]
        }
      end
    end

    def ok?
      true
    end
  end
end
