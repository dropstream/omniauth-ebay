require 'multi_xml'
require 'faraday'

module EbayAPI

  ACTIONS = {
    fetch_auth_token: 'FetchToken',
    get_session_id: 'GetSessionID',
    get_user: 'GetUser'
    
  }

  LIVE_API_ENDPOINT = "https://api.ebay.com/ws/api.dll"
  TEST_API_ENDPOINT = "https://api.sandbox.ebay.com/ws/api.dll"
  
  LIVE_SIGNIN_ENDPOINT = 'https://signin.ebay.com/ws/eBayISAPI.dll'
  TEST_SIGNIN_ENDPOINT = 'https://signin.sandbox.ebay.com/ws/eBayISAPI.dll'
  
  def get_session_id(ru_name)
    request = %Q(
          <?xml version="1.0" encoding="utf-8"?>
          <GetSessionIDRequest xmlns="urn:ebay:apis:eBLBaseComponents">
            <RuName>#{ru_name}</RuName>
          </GetSessionIDRequest>
    )

    response = commit(:get_session_id, request)
    MultiXml.parse(response)["GetSessionIDResponse"]["SessionID"]
  end

  def fetch_auth_token(session_id)
    request = %Q(
      <?xml version="1.0" encoding="utf-8"?>
      <FetchTokenRequest xmlns="urn:ebay:apis:eBLBaseComponents">
        <SessionID>#{session_id}</SessionID>
      </FetchTokenRequest>
    )

    response = commit(:fetch_auth_token, request)
    MultiXml.parse(response)["FetchTokenResponse"]["eBayAuthToken"]
  end

  def get_user(auth_token)
    request = %Q(
      <?xml version="1.0" encoding="utf-8"?>
      <GetUserRequest xmlns="urn:ebay:apis:eBLBaseComponents">
        <RequesterCredentials>
          <eBayAuthToken>#{auth_token}</eBayAuthToken>
        </RequesterCredentials>
      </GetUserRequest>
    )

    response = commit(:get_user, request)
    MultiXml.parse(response)["GetUserResponse"]['User']
  end

  def ebay_login_url(session_id)
    url = "#{signin_endpoint}?SignIn&RuName=#{options.runame}&SessID=#{URI.escape(session_id)}"
    params = request.params.map{|k,v| "#{k}=#{v}"}.join('&')
    url << "&ruparams=#{CGI::escape(params)}" if params

    url
  end

  protected
  
  def commit(action, request_body)

    api_endpoint_uri = URI.parse(api_endpoint)
    conn = Faraday.new(:url => "https://#{api_endpoint_uri.host}", 
                        :headers => api_headers(action)) do |faraday|
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    end

    response = conn.post do |req|
      req.url api_endpoint_uri.path
      req.body = request_body
    end

    response.body
  end

  def api_headers(action)
    {
        'X-EBAY-API-CALL-NAME' => ACTIONS[action],
        'X-EBAY-API-COMPATIBILITY-LEVEL' => '805',
        'X-EBAY-API-DEV-NAME' => options.devid,
        'X-EBAY-API-APP-NAME' => options.appid,
        'X-EBAY-API-CERT-NAME' => options.certid,
        'X-EBAY-API-SITEID' => options.siteid.to_s,
        'Content-Type' => 'text/xml'
    }
  end

  def api_endpoint
    options.is_sandbox == true ? TEST_API_ENDPOINT : LIVE_API_ENDPOINT
  end
  
  def signin_endpoint
    options.is_sandbox == true ? TEST_SIGNIN_ENDPOINT : LIVE_SIGNIN_ENDPOINT
  end

end
