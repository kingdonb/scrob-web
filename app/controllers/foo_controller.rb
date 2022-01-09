require './lib/ecoli/spreadsheet'
require 'ap'

class FooController < ApplicationController
  def bar
    @s = Ecoli::Spreadsheet.new(google_sheet_id: '1vAoOl4xCSPJcIK95FYdZ9C9Q-zxBn-1mLCyEhnVOaBU')
    @w = @s.all_worksheets

    @records = @w[2].records.ai(html: true)
    @title = @w[2].ws_title
    @ok = @w[2].ok?
  end
end
