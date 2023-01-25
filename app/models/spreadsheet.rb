class Spreadsheet

  attr_reader :spreadsheet_key, :spreadsheet_provider

  def initialize(spreadsheet_key = nil , spreadsheet_provider = :google)
    @spreadsheet_key      = spreadsheet_key || ENV['SHEET_ID']
    @spreadsheet_provider = spreadsheet_provider
  end
  
  def worksheets
    @worksheets ||= spreadsheet.worksheets
  end

  def add_sheet(title)
    proxy.create_worksheet(spreadsheet: spreadsheet, title: title)
  end

  ## Row is a multidimensional array, e.g.
  ## [["This", "is", "one", "row"],["And", "another"]]
  def insert_rows(rows, worksheet_title: nil)
    worksheet = worksheet_title.present? ? spreadsheet.worksheet_by_title(worksheet_title) : first_worksheet

    raise "Sheet with title #{worksheet_title} not present in current document #{spreadsheet_key}" unless worksheet.present?

    worksheet.insert_rows(worksheet.num_rows + 1, rows)
    worksheet.save
  end

  private

  def first_worksheet
    @first_worksheet ||= worksheets.first
  end

  def spreadsheet
    @spreadsheet ||= proxy.spreadsheet_by_key(spreadsheet_key)
  end

  def proxy
    @proxy ||= "SpreadsheetProxy::#{spreadsheet_provider.to_s.camelcase}SpreadsheetProxy".constantize.new
  end
end