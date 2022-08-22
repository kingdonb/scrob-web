# typed: strict
require 'forwardable'
require 'csv'

module Steuben
  class OutputSpreadsheet
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

    def output_worksheet
      output_sheet_index = worksheets_titles.find_index("Output Page")
      worksheets[output_sheet_index]
    end

    def read_from(records, header_row)
      @ws = output_worksheet

      header_row.each_with_index do |key, key_idx|
        @ws[1, key_idx+1] = key
        records.each_with_index do |r, idx|
          unless r[key].nil?
            @ws[idx+2, key_idx+1] = r[key]
          end
        end
      end
    end

    def commit
      @ws.save
    end

    def to_csv
      o = ok_worksheets
      r = ok_worksheets.map(&:records)
      f = r.flatten.map{|s| Record.new(s)}
      raise StandardError, "there were no OK spreadsheets" if f.count == 0

      csv_string = CSV.generate do |csv|
        csv << f.first.known_keys # header row
        rows = f.each do |record|
          csv << record.to_csv
        end
      end

      filename = "/tmp/written-#{Time.now.strftime('%s')}.csv"
      File.open(filename, 'w') { |file| file.write(csv_string) }

      @message = "Wrote to '#{filename}' without errors"
      csv_string
    end
  end
end
