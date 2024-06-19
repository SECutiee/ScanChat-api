# frozen_string_literal: true

require 'http'

module ScanChat
  # Find or create an SsoAccount based on Github code
  # Authenticate the user to GitHub using the provided access_token, then find or create a single sign-on (SSO) account in the local application based on the GitHub account information and generate an authorization token.
  class AuthorizeSso
    def call(access_token)
      github_account = get_github_account(access_token)
      sso_account = find_or_create_sso_account(github_account)

      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_user_response = HTTP.headers(
        user_agent: 'ScanChat',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV.fetch('GITHUB_ACCOUNT_URL', nil))

      raise unless gh_user_response.status == 200

      # puts gh_user_response
      gh_email_response = HTTP.headers(
        user_agent: 'ScanChat',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV.fetch('GITHUB_ACCOUNT_EMAIL_URL', nil))

      raise unless gh_email_response.status == 200

      gh_user_response_hash = JSON.parse(gh_user_response)
      gh_email_response_hash = JSON.parse(gh_email_response)

      gh_response = {
        'login' => gh_user_response_hash['login'],
        'email' => gh_email_response_hash[0]['email']
      }

      account = GithubAccount.new(gh_response)
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_github_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account:,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end
