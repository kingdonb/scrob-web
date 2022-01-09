# typed: strict
require 'forwardable'
require 'csv'

module Ecoli
  class Spreadsheet
    extend Forwardable
    def_delegators :@properties, :[], :[]=

    def initialize(google_sheet_id:, scrub_event_id:, previous_event_id:, csvinput_filename:, discussion_csvinput_filename: nil)
      @spreadsheet_id = google_sheet_id
      @config = Config.new(input_file: csvinput_filename, discussion_input_file: discussion_csvinput_filename)
      session = GoogleDrive::Session.from_config(@config.config_json)

      @properties = {
        google_sheet_id:   google_sheet_id,
        session:           session,
      }

      @properties[:ws] =
        session.spreadsheet_by_key(spreadsheet_id).worksheet_by_title("Raw data")
    end

    def pry
      binding.pry
    end
  end
end
