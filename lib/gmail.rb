require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'pry'

module Gmail
  class Service
    def initialize
      @service = Google::Apis::GmailV1::GmailService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = authorize
    end

    def user_id
      'me'
    end

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    APPLICATION_NAME = 'Gmail API Ruby Quickstart'
    CLIENT_SECRETS_PATH = "#{Rails.root}/config/google_api_client_secret.json"
    CREDENTIALS_PATH = "/tmp/gmail-ruby-quickstart.yaml"
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY
    
    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def authorize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(
          base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      end
      credentials
    end

    def method_missing(m, *args, &block)
      @service.send(m.to_sym, *args, &block)
    end

    def messages(options = {})
      @service.list_user_messages('me', options)
    end

    def fs
      messages(max_results: 20, q: "ForexSignals")
    end

    def fx_premiere
      messages(max_results: 10, q: "info@fxpremiere.com")
    end

    def pia_first
      messages(max_results: 6, q: "analysis@pia-first.com")
    end

    def message(id)
      @service.get_user_message('me', id)
    end
  end
end
