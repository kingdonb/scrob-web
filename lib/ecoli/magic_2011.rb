# typed: strict
require 'forwardable'

module Ecoli
  class Magic2011
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

    def sitename_5
      sitenames_row[21]
    end

    def sitename_6
      sitenames_row[26]
    end

    def header_row
      worksheet.rows[2]
    end 

    def records
      [site1_records, site2_records, site3_records, site4_records, site5_records, site6_records].flatten
    end

    def data_rows
      @data_rows ||= worksheet.rows.filter do |row|
        %r{^\d+/\d+/11$} =~ row[0]
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
          temp_c: row[5],
          weather: row[31]
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
          temp_c: row[10],
          weather: row[31]
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
          temp_c: row[15],
          weather: row[31]
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
          do: row[18],
          tss: row[19],
          temp_c: row[20],
          weather: row[31]
        }
      end
    end

    def site5_records
      data_rows.map do |row|
        {
          site: sitename_5,
          date: row[0],
          time: row[21],
          ecoli: row[22],
          do: row[23],
          tss: row[24],
          temp_c: row[25],
          weather: row[31]
        }
      end
    end

    def site6_records
      data_rows.map do |row|
        {
          site: sitename_6,
          date: row[0],
          time: row[26],
          ecoli: row[27],
          do: row[28],
          tss: row[29],
          temp_c: row[30],
          weather: row[31]
        }
      end
    end

    def ok?
      true
    end
  end
end
