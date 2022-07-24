# typed: strict
require 'forwardable'

module Steuben
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

    def magic
      @magic ||=
        "Steuben::Magic#{ws_title}".classify.constantize
        .new(worksheet: self)
    end

    def records
      magic.records
    end

    def worksheet
      self[:worksheet] ||
        self[:worksheet] =
          spreadsheet.worksheet_by_title(ws_title)
    end

    def ok?
      magic&.ok?
    rescue StandardError => e
      false
    end
  end
end
