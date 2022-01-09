# typed: strict
require 'forwardable'

module Ecoli
  class Magic1996 < Magic1995
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/96$} =~ row[0]
      end
    end
  end
end
