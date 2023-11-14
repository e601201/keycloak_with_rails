Rails.application.config.middleware.use OmniAuth::Builder do
  keycloak = Rails.application.credentials.keycloak
  provider :keycloak_openid,
  keycloak[:client],
  keycloak[:secretkey],
  client_options: {
    base_url: '', site: keycloak[:domain], realm: keycloak[:realm]
  },
  name: 'keycloak'
end

# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :keycloak_openid, 'demo-client', 'シークレットコード',
#     client_options: {base_url: '', site: 'http://localhost:8080',
#     realm: 'demo-realm'}, name: 'keycloak'
# end
