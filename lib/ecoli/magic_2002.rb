# typed: strict
require 'forwardable'

module Ecoli
  class Magic2002
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
      worksheet.rows[1]
    end

    def sitename_1
      sitenames_row[1]
    end

    def sitename_2
      sitenames_row[6]
    end

    def sitename_3
      sitenames_row[11]
    end

    def sitename_4
      sitenames_row[16]
    end

    def header_row
      worksheet.rows[2]
    end 

    def records
      [site1_records, site2_records, site3_records, site4_records].flatten
    end

    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/02} =~ row[0]
      end
    end

    def site1_records
      data_rows.map do |row|
        {
          site: sitename_1,
          date: row[0],
          time: row[1],
          ecoli: row[2],
          do: row[3],
          tss: row[4],
          temp_f: row[5],
          rain: row[22]
        }
      end
    end

    def site2_records
      data_rows.map do |row|
        {
          site: sitename_2,
          date: row[0],
          time: row[6],
          ecoli: row[7],
          do: row[8],
          tss: row[9],
          temp_f: row[10],
          rain: row[22]
        }
      end
    end

    def site3_records
      data_rows.map do |row|
        {
          site: sitename_3,
          date: row[0],
          time: row[11],
          ecoli: row[12],
          do: row[13],
          tss: row[14],
          temp_f: row[15],
          rain: row[22]
        }
      end
    end

    def site4_records
      data_rows.map do |row|
        {
          site: sitename_4,
          date: row[0],
          time: row[16],
          ecoli: row[17],
          contact_tank_do: row[18],
          outfall_do: row[19],
          tss: row[20],
          temp_f: row[21],
          rain: row[22]
        }
      end
    end

    def ok?
      true
    end
  end
end
