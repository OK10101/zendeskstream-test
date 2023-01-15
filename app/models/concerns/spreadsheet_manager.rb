class SpreadsheetManager

  attr_reader :spreadsheet_key

  def initialize(spreadsheet_key)
    @spreadsheet_key = spreadsheet_key
  end

  ## Row is a multidimensional array, e.g.
  ## [["This", "is", "one", "row"],["And", "another"]]
  def insert_rows(rows, worksheet_title=nil)
    worksheet = worksheet_title.present? ? worksheets : worksheets.first

    worksheet.insert_rows(worksheet.num_rows + 1, rows)
    worksheet.save
  end

  def worksheets
    spreadsheet.worksheets
  end

  def worksheet_titles
    worksheets.map(&:title)
  end
  
  private

  def spreadsheet
    @spreadsheet ||= proxy.spreadsheet_by_key(spreadsheet_key)
  end

  def proxy
    @proxy ||= SpreadsheetProxy::GoogleSpreadsheetProxy.new
  end
end