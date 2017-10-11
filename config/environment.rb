# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'icalendar'

# Initialize the Rails application.
Rails.application.initialize!

Date::DATE_FORMATS[:date] = '%d/%m/%Y'

Time::DATE_FORMATS[:date] = '%d/%m/%Y'
Time::DATE_FORMATS[:time] = '%H:%M'
Time::DATE_FORMATS[:time_date] = '%H:%M %d/%m/%Y'
Time::DATE_FORMATS[:date_time] = '%d/%m/%Y %H:%M'
