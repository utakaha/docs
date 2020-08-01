# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'google-api-client'
  gem 'googleauth'
  gem 'dotenv'
end

require 'google/apis/docs_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'dotenv/load'

USER_ID = 'default'
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
Dotenv.load

def authorize
  authorizer = Google::Auth::UserAuthorizer.new(
    Google::Auth::ClientId.from_file('credentials.json'),
    Google::Apis::DocsV1::AUTH_DOCUMENTS,
    Google::Auth::Stores::FileTokenStore.new(file: 'token.yaml')
  )
  credentials = authorizer.get_credentials(USER_ID)

  if credentials.nil?
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + authorizer.get_authorization_url(base_url: OOB_URI)
    code = gets

    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: USER_ID,
      code: code,
      base_url: OOB_URI
    )
    credentials
  end
  credentials
end

service = Google::Apis::DocsV1::DocsService.new
service.client_options.application_name = ENV['APPLICATION_NAME']
service.authorization = authorize

p service.create_document(Google::Apis::DocsV1::Document.new(title: Date.today.strftime('%Y/%m/%d')))
