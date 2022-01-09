require './lib/ecoli/spreadsheet'

class FooController < ApplicationController
  def bar
    @s = Ecoli::Spreadsheet.new(google_sheet_id: '1vAoOl4xCSPJcIK95FYdZ9C9Q-zxBn-1mLCyEhnVOaBU')
    @w = @s.all_worksheets
  end
end
