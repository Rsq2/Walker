require 'rubygems'
require 'capybara'
require 'csv'
require_relative './entry.rb'

Capybara.run_server = false
Capybara.current_driver = :selenium

class Texas_Ranger
  include Capybara::DSL

  def initialize
    accepted_formats = [".csv"]
    raise ArgumentError.new("Please enter a .csv file") if accepted_formats.include?(File.extname(ARGV[0])) == false

    @filename = ARGV[0].to_s
    @input = merge_array(ARGV[0])
    @output = CSV.open('directions_data.csv', "w")
  end

# Reformat Array of Arrays from CSV
  def merge_array(array_of_arrays)
    merged = Array.new
    CSV.foreach(array_of_arrays) do |row|
      merged << row.join(' ')
    end
    return merged
  end

# Main Automation
  def round_house
    visit 'https://www.google.com/maps/dir/'

  # The Land of Misfit CSS Selectors
    walk_button = find('div.directions-travel-mode-icon.directions-walk-icon')
    search_button = find('button.searchbutton')
    start = find('#sb_ifc50 > input')
    destination = find('#sb_ifc51 > input')

    walk_button.click
    start.set($start_point)

  # Lookup
    @input.each do |address|
      this_entry = Entry.new(address)
      puts "\nCurrent Entry: #{address}"

      sleep 1
      destination.set(address)
      search_button.click
      sleep 3

    # Output Sequence
      found = test_address(this_entry)
      if found == true
        collect_data(this_entry)
        take_screenshot(address)
        @output << this_entry
      else
        next
      end
    end

  # Termination
    puts "\n Scraping for #{@filename} Complete"
  end

# Catch Sequence For Bad Addresses
  def test_address(entry)
    entry_exists = false

    # Approx. Address
    begin
      if page.has_css?('span.widget-directions-error')
        puts "\t Precision Failure - Exact Address Not Found"
        entry.steps << 'Precision Failure - Exact Address Not Found'
        puts "\t---> Continuing to Next Entry\n"
        return entry_exists = false
      end

    # No Address
      click_link 'Details'
      sleep 3
    rescue Capybara::ElementNotFound
      puts "\tLookup Failure - Address Not Found"
      entry.steps << 'Lookup Failure - Address Not Found'
      puts "\t---> Continuing to Next Entry\n"
      return entry_exists = false
    else

    # Address Found
      return entry_exists = true
    end
  end

# Gather Up That Delicious Data
  def collect_data(entry)
    steps = all('div.numbered-step-content')
    distances =  all('div.directions-mode-distance-time')

  # Pair Array Indices 1:1
    steps.zip(distances).each do |step, distance|
      sleep 1
      entry.steps << distance.text + '--' + step.text
      puts "\tAdding...#{distance.text}--#{step.text}"
    end
  end

  def take_screenshot(route)
        find('div.side-panel-close').click
        save_screenshot(route + '.png')
        puts "\t[Route Screenshot Taken]"
  end
end

# Set start point here!
$start_point = '3203 SE Woodstock Blvd, Portland, OR 97202'

Walker = Texas_Ranger.new
Walker.round_house
