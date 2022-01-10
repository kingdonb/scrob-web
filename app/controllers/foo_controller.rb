require './lib/ecoli/spreadsheet'
require 'ap'

class FooController < ApplicationController
  def bar
    @s = Ecoli::Spreadsheet.new(google_sheet_id: '1vAoOl4xCSPJcIK95FYdZ9C9Q-zxBn-1mLCyEhnVOaBU')
    @w = @s.all_worksheets

    @n_ok = @s.ok_worksheets.count
    @ok_worksheets = @s.ok_worksheets.map(&:ws_title)

    @csv = @s.to_csv

    n = 30  # year = 2021
    # @records  = @w[n].records.ai(html: true)
    # @title    = @w[n].ws_title
    # @ok       = @w[n].ok?
  end
end
