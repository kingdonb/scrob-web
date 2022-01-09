# typed: strict
require 'forwardable'

module Ecoli
  class Worksheet
    extend Forwardable
    def_delegators :@properties, :[], :[]=

    def initialize(spreadsheet:, ws_title:)
      @properties = {
        spreadsheet: spreadsheet,
        worksheet: nil,
        ws_title: ws_title,
      }
    end

    def spreadsheet
      self[:spreadsheet]
    end
    def ws_title
      self[:ws_title]
    end

    def worksheet
      self[:worksheet] ||
        self[:worksheet] =
          spreadsheet.worksheet_by_title(ws_title)
    end

    def ok?
      true
    end
  end
end
