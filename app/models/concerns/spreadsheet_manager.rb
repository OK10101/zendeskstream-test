class SpreadsheetManager
  include Helpers::StringHelper

  attr_reader :spreadsheet, :helpdesk_system, :spreadsheet_provider

  def initialize(spreadsheet, helpdesk_system: :zendesk)
    @spreadsheet      = spreadsheet
    @helpdesk_system  = helpdesk_system
  end

  def stream_tickets(tickets = helpdesk_proxy.tickets)
    tickets.each do |ticket|
      internal_ticket = Ticket.where(external_id: ticket.id).first_or_create

      if ticket.via.try('channel') == 'email' && ticket.via&.source&.to&.name != ENV['ZENDESK_ACCOUNT_NAME']
        puts "Skipping ticket #{ticket.id} because it is NOT inbound"
        next
      end
      
      if ticket.via.try('channel') == 'voice' || ticket.subject.include?('Voicemail')
        puts "Skipping ticket #{ticket.id} because it is a voice call"
        next
      end

      if ticket.comments.size <= 1
        puts "Skipping ticket #{ticket.id} because it doesn't have replies"
        next
      end

      if internal_ticket.imported
        puts "Skipping ticket #{ticket.id} because it is already imported"
        next
      end

      sheet_1_result = spreadsheet.insert_rows(prepare_row(ticket), worksheet_title: ENV['SHEET_1_TITLE'])
      sheet_2_result = spreadsheet.insert_rows(prepare_simple_row(ticket), worksheet_title: ENV['SHEET_2_TITLE'])
      
      if sheet_1_result && sheet_2_result
        internal_ticket.update(imported: true) 
      end

      puts "Ticket #{ticket.id} successfully imported"

      # Sleep to prevent spreadsheet quota exhaustion
      sleep 2

      sheet_1_result && sheet_2_result
    end

    true
  rescue => e
    puts "ERROR HAPPENED -> #{e.message}"

    false
  end

  private

  def prepare_row(ticket)
    comments = ticket.comments
    customer_question = remove_non_required_reply(comments[0].body)
    agent_response    = remove_non_required_reply(comments[1].body)

    ## ROW FORMAT
    ## Customer Q, Reply, Best reply, Score, Ticket#, Date, Customer email, Agent email
    [
      [
        customer_question, 
        agent_response, 
        '', 
        '1-10', 
        ticket.id, 
        ticket.created_at.in_time_zone(ENV['TIME_ZONE'] || 'EST').strftime('%Y-%m-%d %H:%M %Z'), 
        ticket.via&.source&.from&.address,
        ticket.assignee.try(:email)
      ]
    ]
  end

  def prepare_simple_row(ticket)
    description = remove_non_required_reply(ticket.description)

    ## ROW FORMAT
    ## Customer Q, Ticket ID, Date
    [
      [
        description,
        ticket.id,
        ticket.created_at.in_time_zone(ENV['TIME_ZONE'] || 'EST').strftime('%Y-%m-%d %H:%M %Z')
      ]
    ]
  end

  def helpdesk_proxy
    @helpdesk_proxy ||= "HelpdeskProxy::#{helpdesk_system.to_s.camelcase}Proxy".constantize.new
  end
end