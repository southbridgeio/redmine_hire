module Hh
  module OAuth
    module_function

    def client
      OAuth2::Client.new(Setting.plugin_redmine_hire['client_id'], Setting.plugin_redmine_hire['client_secret'], site: 'https://hh.ru')
    end

    def redirect_uri
      Addressable::URI.parse("#{Setting['protocol']}://#{Setting['host_name']}/redmine_hire/oauth").to_s
    end

    TOKENS_URL = 'https://hh.ru/oauth/token'

    def fetch_tokens(code)
      client_id, client_secret = Setting.plugin_redmine_hire.values_at('client_id', 'client_secret')

      response = RestClient.post(TOKENS_URL,
                                 grant_type: 'authorization_code',
                                 client_id: client_id,
                                 client_secret: client_secret,
                                 redirect_uri: redirect_uri,
                                 code: code
      )

      handle_tokens_response(response)
    end

    def reissue_tokens
      response = RestClient.post(TOKENS_URL,
                                 grant_type: 'refresh_token',
                                 refresh_token: Setting.plugin_redmine_hire['refresh_token']
      )

      handle_tokens_response(response)
    end

    private

    module_function

    def handle_tokens_response(response)
      payload = JSON.parse(response.body)

      return false if payload['error']

      settings = Setting.find_by(name: 'plugin_redmine_hire')
      settings.value = settings.value.merge(payload.slice('access_token', 'refresh_token'))
      settings.save
    end
  end
end
