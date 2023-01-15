require 'zendesk_api'

class HelpdeskProxy::ZendeskProxy < HelpdeskProxy::Base

  CONFIG_FILE_PATH = 'config/zendesk/credentials.json'

  def tickets(sort_by: :created_at, sort_order: :desc)
    client.tickets(sort_by: sort_by, sort_order: sort_order)
  end

  private

  def default_credentials
    file = File.read(config_absolute_path)

    JSON.parse(file).deep_symbolize_keys
  end

  def config_absolute_path
    @config_absolute_path ||= Rails.root.join(CONFIG_FILE_PATH).to_s
  end

  def client
    @client ||= begin
      ZendeskAPI::Client.new do |config|
        config.url      = credentials[:url]
        config.username = credentials[:username]
        config.token    = credentials[:token]
      end
    end
  end
end