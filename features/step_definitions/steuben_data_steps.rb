Given('we start from the webpage where the data is kept updated') do
  @w = '1Mtd3oiR8dI0Df5tSwdwOISFbpGo4ATnW-zQISb_mye8'
  @overall_retries = 0
  @high_water_retries = 0
  # FIXME: this Google Sheet ID just represents a snapshot of the website data
end

Given('we have downloaded a spreadsheet full of many tabs of mostly similar data') do
  @s = Steuben::Spreadsheet.new(google_sheet_id: @w)
  @ts = @s.worksheets_titles
  a = 1..90
  b = a.to_a
  b.delete(85)
  @c = b.map(&:to_s).
    map do |y|
      {y => @ts.find_index(y)}
    end
  # Lazy downloaded
end

def ws(tab_index)
  @s.worksheets[tab_index]
end

def with_retries
  max_retries = 8
  retries = 0
  if retries > @high_water_retries
    @high_water_retries = retries
  end

  ret = yield

  return ret
rescue Google::Apis::RateLimitError => e
  if retries <= max_retries
    retries += 1; @overall_retries += 1
    max_sleep_seconds = Float(2 ** retries)
    sleep rand(0..max_sleep_seconds)
    retry
  else
    raise "Giving up on the server after #{retries} retries. Got error: #{e.message}"
  end
end

def get_top_label(tab_index)
  with_retries do
    ws(tab_index)[1,1]
  end
end

def parse_tab_label_via_regex(tab_label, tab_index)
  label_field = get_top_label(tab_index)

  r = /^Tab +(\d+) ?,(.+),( |[^\d].+)$/
  m = label_field.match(r)

  # FIXME: finished program should not include rspec expectations in it
  binding.pry if m.nil?
  expect(label_field).to match(r)

  matched_label = m[1].strip
  site_number = m[2].strip
  site_label = m[3].strip

  # Note: at least one tab label does not match inner tab number, so
  # this expectation would not succeed! :(
  # expect(tab_label).to eq(matched_label)

  {
    tab_index: tab_index,
    tab_number: tab_label,
    inner_tab_number: matched_label,
    site_number: site_number,
    site_label: site_label
  }
end

When('the site name is located on a numbered tab') do
  @site_map = @c.map do |tab_tuple|
    tab_tuple.map do |tab_label_number, tab_index|
      dont_filter_here = false

      # FIXME: In the finished program, we should not filter here...
      if tab_label_number == "5" # ||
        # tab_label_number == "25" ||
        # tab_label_number == "30" || dont_filter_here
        parse_tab_label_via_regex(tab_label_number, tab_index)
      else
        nil
      end
    end
  end.flatten.compact
end

def variable_list(tab_index)
  labels = []
  # Row 0 is the tab/top label row and has already been read before
  # Row 1 is Sampling Date row, and subsequent rows are variables
  (1..).map do |n|
    variable_label = with_retries { ws(tab_index).rows[n][0] }

    # Any row without a variable label is assumed to be an empty row
    if variable_label != ""
      # The BDL row signals we are at the beginning of the legend
      # (and therefore have reached the end of the variable list)
      if variable_label == "BDL= below detection limit"
        break # so we stop reading here, there's no more data rows
      end
      labels << {row_index: n, l: variable_label}
    end
  end
  labels
end

When('the numbered tabs all contain different variables in each row') do
  @site_map.each do |h|
    l = variable_list(h[:tab_index])
    labels = l.map{|ls| ls[:l]}
    expect(l).to include({l: "Sampling Date", row_index: 1})
    expect(labels).to include("Sampling Date")
    expect(labels).to include("TKN Loading")
    expect(labels).to include("D.O.")
    # FIXME: ... assert any required labels, assert labels are consistent, etc.
  end
end

When('the dates are column headers') do

  puts "Stats"
  puts "----------------------"
  puts "Overall retries: #{@overall_retries}"
  puts "Retries high water: #{@high_water_retries}"

  pending
end

When('the data is gathered from the many tabs into one list of records') do
  pending # Write code here that turns the phrase above into concrete actions
end

When('the tabs labeled {string} and {string} can be ignored') do |string, string2|
  pending # Write code here that turns the phrase above into concrete actions
end

Then('each record in the list is written into the output spreadsheet') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('each column represents a variable, an observation date, or the site name') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('each row represents an observation of one or more of the variables') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the site name is added to the end of each row in an additional column') do
  pending # Write code here that turns the phrase above into concrete actions
end
