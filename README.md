## Walker - Google Directions Scraper 
by D.J. Dykes
=======================
Thanks for taking the time to view my work. 

This is a browser automation written using Capybara and Selenium webdriver that will take a list of addresses (.csv) and dump walking directions from a starting point to each address into a separate (.csv) file. It will also take a route screenshot upon successful lookup

A list of failed addresses is also compiled and placed into a separate file for cleanup / troubleshooting.


## Running Instructions

This script takes the path of your addresses.csv as its first ARGV. A sample .csv has been included that displays the program's functionality and error handling capabilities.

It may be run by cloning the repository, changing to its directory, then using the following snippet:

  ```bash
  % ruby walker.rb sample.csv
  ```
