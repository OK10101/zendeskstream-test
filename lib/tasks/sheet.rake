require 'rake'

namespace :sheet do
  desc 'Stream tickets and write to spreadsheets'
  task :stream => :environment do
    
    puts "Executing sheet:stream at #{Time.now}/n"
    
    sheet = Spreadsheet.new(ENV['SHEET_ID'])

    manager = SpreadsheetManager.new(sheet)
    manager.stream_tickets

    puts "Finished executing sheet:stream at #{Time.now}/n/n"
  end
end
