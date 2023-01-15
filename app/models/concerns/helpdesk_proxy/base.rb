class HelpdeskProxy::Base

  attr_reader :credentials

  def initialize(credentials = {})
    @credentials = credentials.present? ? credentials.deep_symbolize_keys : default_credentials
  end

end