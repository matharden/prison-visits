SERVICE_DOMAIN = (url = ENV['SERVICE_URL']) ? URI.parse(url).host : nil

{key: 'pvbs', expire_after: 20.minutes, httponly: true, max_age: 20.minutes.to_s, domain: SERVICE_DOMAIN}.tap do |configuration|
  configuration[:secure] = ( ENV['COOKIE_SECURE'] == 'True' )
  PrisonVisits2::Application.config.session_store :cookie_store, configuration
end
