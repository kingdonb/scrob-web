# typed: strict
require 'forwardable'

module Ecoli
  class Magic2006 < Magic2005
    def sitename_4
      sitenames_row[16]
    end

    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/2006$} =~ row[0]
      end
    end
  end
end
