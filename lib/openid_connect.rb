require 'rubygems'
require 'base64'
require 'rest-client'
require 'json'
require 'uri'   
require 'securerandom'

class OpenIdConnect

  attr_accessor :client_key, :client_secret, :response_type, :auth_endpoint, :token_endpoint, :redirect_uri

  def initialize(ck: client_key, cs: client_secret, rt: response_type, sc: "openid", ae: auth_endpoint, te: token_endpoint, ru: redirect_uri, nonce: nil, st: nil)

    # Credentials
    @client_key = ck
    @client_secret = cs
    @response_type = rt || "code"

    # Endpoints
    @auth_endpoint = ae
    @token_endpoint = te
    @redirect_uri = ru

    # Strings to confirm the request is coming from the same place
    @nonce = nonce || create_nonce
    @state = st || create_state
    @auth_str = base64_string

    # Specifies what you're asking for
    @scope = sc
    @auth_response = nil
    
    # Requests info for auth code
    @auth_req = nil
    @auth_code = nil
    @auth_response = nil

    # Requests info for tokens
    @token_req = nil
    @token = nil
    @token_response = nil

    # Correct endpoints
    normalize_uris
  end
  def get_auth_code
    qs = create_qs(escape_qs({ client_id: @client_key, response_type: @response_type, redirect_uri: @redirect_uri, scope: @scope, nonce: @nonce }))
    begin
      @auth_req = RestClient::Request.new(
         :method => :get,
         :url => @auth_endpoint + "?" + qs,
         :headers => { :accept => "application/json", :content_type => "application/json" }
       )
    rescue RestClient::RequestFailed => e
      puts "There was an issue with the request."
      p @auth_req
      p e.message
    rescue RestClient::Exception => e
      p @auth_req
      puts "Something went wrong with the request."
      p e.message
    end 
    @auth_response = execute_request(@auth_req, @auth_endpoint)
  end
  def get_id_token

  end
  def get_access_token

  end
  private
  def escape_qs(qs)
     qs.keys.each do |k|
        qs[k] = URI.escape("#{qs[k]}")
     end
     return qs
  end
  def execute_request(req, endpoint)
    begin 
      response = req.process_result(req.execute)
    rescue RestClient::RequestFailed => e
      printf("Request failed: Error Code: %-4s Error Message: %-20s\n", e.http_code, e.message)
      puts "Endpoint: #{endpoint}, Response: #{response}"
      raise
    rescue RestClient::RequestTimeout => e
      printf("Request timed out: Error Code: %-4s Error Message: %-20s\n", e.http_code, e.message)
      puts "Endpoint: #{endpoint}, Response: #{response}"
      raise
    rescue IOError => e
      # TBD: Have to figure out why the message 'not opened for reading' is being outputted.
      printf("Error Code: %-4s Error Message: %-20s\n", e.http_code, e.message)
      raise
    end
    response
  end
  def create_qs(args={})
    qs = ""
    args.keys.each do |k|
      qs += k.to_s + "=" + args[k] + "&" 
    end 
    qs.chop
  end
  def create_state
    SecureRandom.uuid 
  end
  def base64_string
    Base64.encode64(@client_key + ":" + @client_secret)
  end
  def create_nonce
    SecureRandom.urlsafe_base64(6)
  end
  def normalize_uris
    http = Regexp.new(/^http:\/\//)
    https = Regexp.new(/^https:\/\//)

    unless http.match(@redirect_uri) || https.match(@redirect_uri)
      @redirect_uri = "http://" + @redirect_uri 
    end
    unless http.match(@auth_endpoint) || https.match(@auth_endpoint)
      @auth_endpoint = "https://" + @auth_endpoint 
    end
    unless http.match(@token_endpoint) || https.match(@token_endpoint)
      @token_endpoint = "https://" + @token_endpoint 
    end
  end
end
