class SpreadsheetStreamer

  attr_reader :spreadsheet_key, :helpdesk_system, :spreadsheet_provider

  def initialize(spreadsheet_key, helpdesk_system: :zendesk, spreadsheet_provider: :google)
    @spreadsheet_key      = spreadsheet_key
    @helpdesk_system      = helpdesk_system
    @spreadsheet_provider = spreadsheet_provider
  end

  def stream
    helpdesk_proxy.tickets.each do |ticket|
      puts ticket.subject
    end

    true
  end

  private

  def spreadsheet_manager
    @spreadsheet_manager ||= SpreadsheetManager.new(spreadsheet_key, spreadsheet_provider: spreadsheet_provider)
  end

  def helpdesk_proxy
    @helpdesk_proxy ||= "HelpdeskProxy::#{helpdesk_system.to_s.camelcase}Proxy".constantize.new
  end
end