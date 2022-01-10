# typed: strict
require 'forwardable'

module Ecoli
  class Magic2017 < Magic2012
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/17$} =~ row[0]
      end
    end
  end
end
