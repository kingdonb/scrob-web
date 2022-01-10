# typed: strict
require 'forwardable'

module Ecoli
  class Magic2009 < Magic2008
    def data_rows
      worksheet.rows.filter do |row|
        %r{^\d+/\d+/09$} =~ row[0]
      end
    end
  end
end
