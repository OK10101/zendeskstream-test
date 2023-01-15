require 'rake'

namespace :sheet do
  desc 'Stream tickets and write to spreadsheets'
  task :stream => :environment do
    sheet = Spreadsheet.new(ENV['SHEET_ID'])

    manager = SpreadsheetManager.new(sheet)
    manager.stream_tickets
  end

  task :invoke_stream do
    # id = ENV['SHEET_ID']
    id = 'iz rake-a'
    Spreadsheet.new(ENV['SHEET_ID']).insert_rows([[id]])
  end
end
