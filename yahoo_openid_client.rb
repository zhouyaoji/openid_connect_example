require_relative './lib/openid_connect.rb'


ck = "dj0yJmk9WGx0QlE0UWdCa0hKJmQ9WVdrOWNrNUhXVnBhTkhFbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD01OA--"
cs = "5bf3390157ef6c90994eccf4614af6fb6a4528d3"
rt = "id_token"
req_endpoint = "https://api.login.yahoo.com/oauth2/request_auth"
token_endpoint = "https://login.yahoo.com/oauth2/get_token"
redirect_uri = "yahoo.com"

yahoo_openid = OpenIdConnect.new(ck: ck, cs: cs, rt: rt, ae: req_endpoint, te: token_endpoint, ru: redirect_uri)

puts "CK: " + yahoo_openid.client_key
puts "CS: " +  yahoo_openid.client_secret
puts "Response type: " +  yahoo_openid.response_type
puts "Auth Endpoint: " + yahoo_openid.auth_endpoint
puts "Redirect URI: " + yahoo_openid.redirect_uri


puts yahoo_openid.get_auth_code


