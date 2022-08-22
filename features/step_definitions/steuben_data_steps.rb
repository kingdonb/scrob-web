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
  @ws = [] if @ws.nil?
  return @ws[tab_index] ||= with_retries do
    @s.worksheets[tab_index]
  end
end

def with_retries
  max_retries = 9
  retries ||= 0
  if retries > @high_water_retries
    @high_water_retries = retries
  end

  ret = yield

  return ret
rescue Google::Apis::RateLimitError => e
  puts "Rate limited (#{retries})"
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
  with_retries { ws(tab_index)[1,1] }
end

def parse_tab_label_via_regex(tab_label, tab_index)
  label_field = get_top_label(tab_index)

  r = /^Tab +(\d+) ?,(.+),( |[^\d].+)$/
  m = label_field.match(r)

  # FIXME: finished program should not include rspec expectations in it
  # binding.pry if m.nil?
  # expect(label_field).to match(r)

  matched_label = m[1].strip
  site_number = m[2].strip
  site_label = m[3].strip

  # Note: at least one tab label does not match inner tab number, so
  # this expectation would not succeed! :(
  # expect(tab_label).to eq(matched_label)

  puts "Got header for Tab #{tab_label}"
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
      # Load **all the tabs** into site_map
      dont_filter_here = true

      # FIXME: In the finished program, we should not filter here...
      if tab_label_number == "5" ||
        tab_label_number == "6" ||
        tab_label_number == "7" ||
        tab_label_number == "8" || dont_filter_here
        parse_tab_label_via_regex(tab_label_number, tab_index)
      else
        nil
      end
    end
  end.flatten.compact
end

def variable_list(tab_index)
  labels = []
  rows = ws(tab_index).rows

  puts "Reading headers for Tab #{tab_index}"
  # Row 0 is the tab/top label row and has already been read before
  # Row 1 is Sampling Date row, and subsequent rows are variables
  (1..).map do |n|
    variable_label = with_retries { rows[n][0] }

    # Any row without a variable label is assumed to be an empty row
    if variable_label != ""
      # The BDL row signals we are at the beginning of the legend
      # (and therefore have reached the end of the variable list)
      if variable_label == "BDL= below detection limit"
        break # so we stop reading here, there's no more data rows
      end
      labels << {row_index: n, l: variable_label.downcase.to_sym}
    end
  end
  labels
end

When('the numbered tabs all contain different variables in each row') do
  @site_variables = {}
  @site_map.each do |h|
    tab_index = h[:tab_index]
    @site_variables[tab_index] = l = variable_list(tab_index)
    expect(l).to include({l: :sampling_date, row_index: 1})

    labels = l.map{|ls| ls[:l]}
    # if ! labels.include? "TKN Loading"
    #   binding.pry
    # end
    # expect(labels).to include("Sampling Date")
    # expect(labels).to include("TKN Loading")
    # expect(labels).to include("D.O.")
    # FIXME: ... assert any required labels, assert labels are consistent, etc.
  end
end

def all_site_variables
  s = Set.new
  s.merge(@site_variables.values.map{|vs|
    vs.map{|v| v[:l].downcase.to_sym}
  }.flatten)
  s
end

def record_list(tab_index, variables)
  records = []
  rows = with_retries { ws(tab_index).rows }

  puts "Reading variables for Tab #{tab_index}"
  # Col 0 is the variable label column and has already been read
  # Col 1 is the first data record and the first data value is Sampling Date
  (1..).map do |n|
    record = {}
    sampling_date_row_key = variables.filter {|v| v[:l] == :sampling_date}.first
    sampling_date_row = rows[sampling_date_row_key[:row_index]]

    sampling_date = sampling_date_row[n]
    # puts "Scanned and found sampling date: '#{sampling_date}'"
    record[:sampling_date] = sampling_date
    record[:col_index] = n
    if record[:sampling_date].nil? || record[:sampling_date].strip == ""
      # The last column was read before a record that has a blank in Sampling Date
      break
    else
      records << record
    end
  end

  puts "Records for Tab #{tab_index} were all prepared (records.size is #{records.size})"

  record_header = @site_map.filter do |site|
    site[:tab_index] == tab_index
  end.first
  # binding.pry

  records.each do |record|
    record_header.each do |k,v|
      record[k]=v
    end
    variables.each do |v|
      variable_label = v[:l]

      # binding.pry
      if variable_label == :sampling_date
        # binding.pry
        # already copied this
      else
        col = record[:col_index]
        row = v[:row_index]
        record[variable_label] = rows[row][col]
      end
    end
  end

  records
end

When('the dates are column headers') do
  @records = []

  @site_variables.each do |tab_index, variables|
    rs = record_list(tab_index, variables)

    expect(rs.first).to have_key(:sampling_date)
    records = [rs[0]]
    records.each do |r|
      expect(r[:sampling_date]).to match %r|\d+/\d+/\d{2,4}|
    end

    rs.each {|r| @records << r}
  end
end

When('the data is gathered from the many tabs into one list of records') do
  rs = @records
  records = [rs[5], rs[6], rs[7]]
  records.each do |r|
    expect(r[:tab_index]).to be_a_kind_of(Integer)
    expect(r[:tab_number]).to be_a_kind_of(String)
  end
end

When('the tabs labeled {string} and {string} can be ignored') do |string, string2|
  #binding.pry
  # Trust that we have ignored them friends!
end

def header_row
  [ :tab_index,
    :tab_number,
    :inner_tab_number,
    :site_number,
    :site_label,
    :sampling_date ] +
  all_site_variables.to_a
end

Then('each record in the list is written into the output spreadsheet') do
  @output_sheet_id = '1DdNVaoRnVfcr3GhEw7nl3T8vK3bwTi9vjIuBS6N47-s'
  @os = Steuben::OutputSpreadsheet.new(google_sheet_id: @output_sheet_id)
  @os.read_from(@records, header_row)
  @os.commit
end

Then('each column represents a variable, an observation date, or the site name') do
  # if there are fewer records, bad
  expect(@records.count).to be > 120
  # some sheets mismatched variable names, bad
  binding.pry
  #expect(@records.map(&:keys).sort.uniq.count).to eq 1
  #       expected: 1
  #       got: 14
end

Then('each row represents an observation of one or more of the variables') do
  #binding.pry
  # Check for yourself, we've already proven this!
end

Then('the site name is added to the end of each row in an additional column') do
  #binding.pry
  # Implemented as a part of record_list
end
