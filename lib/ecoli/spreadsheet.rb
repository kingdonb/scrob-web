# typed: strict
require 'forwardable'
require 'csv'

module Ecoli
  class Spreadsheet
    extend Forwardable
    def_delegators :@properties, :[], :[]=

    def initialize(google_sheet_id:)
      @spreadsheet_id = google_sheet_id
      @config = Config.new()
      session = GoogleDrive::Session.from_config(@config.config_json)

      @properties = {
        google_sheet_id:   google_sheet_id,
        session:           session,
      }

      @properties[:ws] =
        session.spreadsheet_by_key(spreadsheet_id)
    end

    def spreadsheet_id
      @spreadsheet_id
    end

    def worksheets
      self[:ws].worksheets
    end

    def worksheet_by_title(title)
      self[:ws].worksheet_by_title(title)
    end

    def worksheets_titles
      worksheets.map(&:title)
    end

    def all_worksheets
      worksheets_titles.map do |title|
        Worksheet.new(spreadsheet: self, ws_title: title)
      end
    end

    def ok_worksheets
      @ok_worksheets ||=
      all_worksheets.map do |worksheet|
        if worksheet.ok?
          worksheet
        else
          nil
        end
      end.compact
    end

    def to_csv
      o = ok_worksheets
      r = ok_worksheets.map(&:records)
      f = r.flatten.map{|s| Record.new(s)}
      csv_string = CSV.generate do |csv|
        csv << f.first.known_keys # header row
        rows = f.each do |record|
          csv << record.to_csv
        end
      end
    end
  end
end
