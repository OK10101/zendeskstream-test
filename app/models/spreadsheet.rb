class Spreadsheet

  attr_reader :spreadsheet_key, :spreadsheet_provider

  def initialize(spreadsheet_key, spreadsheet_provider: :google)
    @spreadsheet_key      = spreadsheet_key
    @spreadsheet_provider = spreadsheet_provider
  end

  ## Row is a multidimensional array, e.g.
  ## [["This", "is", "one", "row"],["And", "another"]]
  def insert_rows(rows, worksheet_title=nil)
    worksheet = worksheet_title.present? ? worksheets : worksheets.first

    worksheet.insert_rows(worksheet.num_rows + 1, rows)
    worksheet.save
  end

  private
  
  def worksheets
    spreadsheet.worksheets
  end

  def spreadsheet
    @spreadsheet ||= proxy.spreadsheet_by_key(spreadsheet_key)
  end

  def proxy
    @proxy ||= "SpreadsheetProxy::#{spreadsheet_provider.to_s.camelcase}SpreadsheetProxy".constantize.new
  end
end