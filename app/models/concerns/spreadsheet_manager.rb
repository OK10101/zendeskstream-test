class SpreadsheetManager

  attr_reader :spreadsheet, :helpdesk_system, :spreadsheet_provider

  def initialize(spreadsheet, helpdesk_system: :zendesk)
    @spreadsheet      = spreadsheet
    @helpdesk_system  = helpdesk_system
  end

  def stream_tickets
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

      result = spreadsheet.insert_rows prepare_row(ticket)
      
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

  def helpdesk_proxy
    @helpdesk_proxy ||= "HelpdeskProxy::#{helpdesk_system.to_s.camelcase}Proxy".constantize.new
  end
end