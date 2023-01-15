require 'zendesk_api'

class SpreadsheetProxy::GoogleSpreadsheetProxy < SpreadsheetProxy::Base

  CONFIG_FILE_PATH = 'config/spreadsheet/service_account_credentials.json'

  def spreadsheet_by_key(key)
    session.spreadsheet_by_key(key)
  end

  private

  def default_credentials
    absolute_credentials_path
  end

  def absolute_credentials_path
    @absolute_credentials_path ||= Rails.root.join(CONFIG_FILE_PATH).to_s
  end

  def session
    @session ||= GoogleDrive::Session.from_service_account_key(absolute_credentials_path)
  end
end