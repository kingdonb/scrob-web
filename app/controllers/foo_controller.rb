require './lib/ecoli/spreadsheet'
require 'ap'

class FooController < ApplicationController
  def bar
    @f = "Foo Bar"

    @s = Steuben::Spreadsheet.new(google_sheet_id: '1Mtd3oiR8dI0Df5tSwdwOISFbpGo4ATnW-zQISb_mye8')
    @w = @s.all_worksheets

    @n_ok = @s.ok_worksheets.count
    @ok_worksheets = @s.ok_worksheets.map(&:ws_title)

    @csv = @s.to_csv

    # n = 30  # year = 2021
    # @records  = @w[n].records.ai(html: true)
    # @title    = @w[n].ws_title
    # @ok       = @w[n].ok?
  end
end
