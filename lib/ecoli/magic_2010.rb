# typed: strict
require 'forwardable'

module Ecoli
  class Magic2010 < Magic2008
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/10$} =~ row[0]
      end
    end
  end
end
