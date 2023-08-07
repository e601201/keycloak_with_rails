Rails.application.config.middleware.use OmniAuth::Builder do
  provider :keycloak_openid, 'demo-client', 'AN8p731FGs0aCFlcmCUMT7NW3n7qvdbp',
    client_options: {base_url: '', site: 'http://localhost:8080',
    realm: 'demo-realm'}, name: 'keycloak'
end

# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :keycloak_openid, 'demo-client', 'シークレットコード',
#     client_options: {base_url: '', site: 'http://localhost:8080',
#     realm: 'demo-realm'}, name: 'keycloak'
# end