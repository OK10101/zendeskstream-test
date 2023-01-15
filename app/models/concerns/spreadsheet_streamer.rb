class SpreadsheetStreamer

  attr_reader :spreadsheet_key, :helpdesk_system, :spreadsheet_provider

  def initialize(spreadsheet_key, helpdesk_system: :zendesk, spreadsheet_provider: :google)
    @spreadsheet_key      = spreadsheet_key
    @helpdesk_system      = helpdesk_system
    @spreadsheet_provider = spreadsheet_provider
  end

  def stream
    helpdesk_proxy.tickets.each do |ticket|

      internal_ticket = Ticket.where(external_id: ticket.id).first_or_create

      if ticket.comments.size <= 1
        puts "Skipping ticket #{ticket.id} because it doesn't have replies"
        next
      end

      if internal_ticket.imported
        puts "Skipping ticket #{ticket.id} because it is already imported"
        next
      end

      result = spreadsheet_manager.insert_rows prepare_row(ticket)
      
      if result
        internal_ticket.update(imported: true) 
      end

      result
    end

    true
  end

  private

  def prepare_row(ticket)
    comments = ticket.comments
    customer_question = comments[0].body
    agent_response    = comments[1].body

    ## ROW FORMAT
    ## Customer Q, Reply, Best reply, Score, Ticket#, Date, Customer email, Agent
    [[customer_question, agent_response, '', 'TBA', ticket.id, ticket.created_at, ticket.via.dig('source', 'from', 'address'), ticket.assignee_id]]
  end

  def spreadsheet_manager
    @spreadsheet_manager ||= SpreadsheetManager.new(spreadsheet_key, spreadsheet_provider: spreadsheet_provider)
  end

  def helpdesk_proxy
    @helpdesk_proxy ||= "HelpdeskProxy::#{helpdesk_system.to_s.camelcase}Proxy".constantize.new
  end
end