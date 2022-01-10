# typed: strict
require 'forwardable'

module Ecoli
  class Magic1999 < Magic1998
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/99$} =~ row[0]
      end
    end
  end
end
