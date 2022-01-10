# typed: strict
require 'forwardable'

module Ecoli
  class Magic2016 < Magic2012
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/16$} =~ row[0]
      end
    end
  end
end
