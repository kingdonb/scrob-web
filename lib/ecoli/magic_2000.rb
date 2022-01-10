# typed: strict
require 'forwardable'

module Ecoli
  class Magic2000 < Magic1998
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/00$} =~ row[0]
      end
    end
  end
end
