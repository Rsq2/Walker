# Submission by D.J. Dykes

require 'rubygems'
require 'capybara'
require 'csv'

Capybara.run_server = false
Capybara.current_driver = :selenium

class Texas_Ranger
  include Capybara::DSL

  def initialize
    unless ARGV[0].include? '.csv'
      raise ArgumentError,
        "Cannot process non-.csv filetypes, enter a .csv as first argument variable"
    end

  # Reformat Array of Arrays from CSV into a single @input array
    @input = Array.new
    CSV.foreach(ARGV[0]) do |row|
      @input << row.join(' ')
    end
 
    @output = CSV.open('directions_data.csv', "w")
    @dump = CSV.open('failed_addresses.csv', "w") 
    
    visit 'https://www.google.com/maps/dir/'
  end

# Main Automation
  def round_house

  # The Land of Misfit CSS Selectors
    walk_button = find('div.directions-travel-mode-icon.directions-walk-icon')
    search_button = find('button.searchbutton')
    start = find('#sb_ifc50 > input')
    destination = find('#sb_ifc51 > input')
    
    walk_button.click
    start.set('400 SW 6th Ave #902, Portland, OR 97204')

    @input.each do |address|
      sleep 1
      destination.set(address)
      search_button.click
      sleep 3

      this_entry = [address]
      puts "\nCurrent Entry: #{address}"

    # Output Sequence      
      found = test_address(this_entry)
      if found == true 
        collect_data(this_entry)
        take_screenshot(address)
        @output << this_entry

      else
        @dump << this_entry
        next
      end
    end

  # Termination
    puts "\n Scraping for #{ARGV[0]} Complete"
  end

# Gather Up That Delicious Data
  def collect_data(entry)
    steps = all('div.numbered-step-content')
    distances =  all('div.directions-mode-distance-time')
  
  # Pair Array Indices
    steps.zip(distances).each do |step, distance|
      sleep 1
      entry << distance.text + '--' + step.text
      puts "\tAdding...#{distance.text}--#{step.text}"
    end
  end

# Catch For Bad Addresses
  # TODO: Refactor to split off error case structure
  def test_address(entry)
    validity = false
    
    begin
      if page.has_css?('span.widget-directions-error')
        puts "\t Non-Critical Error: Precision Failure - Exact Address Not Found"
        entry << 'Precision Failure - Exact Address Not Found'
        puts "\t---> Continuing to Next Entry\n"
        return validity
      end

      click_link 'Details'
      sleep 3

    rescue Capybara::ElementNotFound
      puts "\tNon-Critical Error: Lookup Failure - Address Not Found"
      entry << 'Lookup Failure - Address Not Found'
      puts "\t---> Continuing to Next Entry\n"
      return validity
    end

    validity = true
    return validity
  end

  def take_screenshot(route)
        find('div.side-panel-close').click
        save_screenshot(route + '.png')
        puts "\t[Route Screenshot Taken]"
  end
end

Walker = Texas_Ranger.new
Walker.round_house
