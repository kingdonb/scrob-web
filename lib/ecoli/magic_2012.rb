# typed: strict
require 'forwardable'

module Ecoli
  class Magic2012 < Magic2005
    def sitename_4
      sitenames_row[16]
    end

    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/12$} =~ row[0]
      end
    end
  end
end
