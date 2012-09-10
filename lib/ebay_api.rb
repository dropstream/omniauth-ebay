require 'multi_xml'

module EbayAPI

  X_EBAY_API_REQUEST_CONTENT_TYPE = 'text/xml'
  X_EBAY_API_COMPATIBILITY_LEVEL = '675'
  X_EBAY_API_GETSESSIONID_CALL_NAME = 'GetSessionID'
  X_EBAY_API_FETCHAUTHTOKEN_CALL_NAME = 'FetchToken'
  X_EBAY_API_GETUSER_CALL_NAME = 'GetUser'

  def generate_session_id
    request = %Q(
          <?xml version="1.0" encoding="utf-8"?>
          <GetSessionIDRequest xmlns="urn:ebay:apis:eBLBaseComponents">
            <RuName>#{options.runame}</RuName>
          </GetSessionIDRequest>
    )

    response = api(X_EBAY_API_GETSESSIONID_CALL_NAME, request)
    MultiXml.parse(response)["GetSessionIDResponse"]["SessionID"]
  end

  def get_auth_token(session_id, user_name)
    request = %Q(
      <?xml version="1.0" encoding="utf-8"?>
      <FetchTokenRequest xmlns="urn:ebay:apis:eBLBaseComponents">
        <RequesterCredentials>
          <Username>#{user_name}</Username>
        </RequesterCredentials>
        <SecretID>#{session_id}</SecretID>
      </FetchTokenRequest>
    )

    response = api(X_EBAY_API_FETCHAUTHTOKEN_CALL_NAME, request)
    MultiXml.parse(response)["FetchTokenResponse"]["eBayAuthToken"]
  end

  def get_user_info(auth_token)
    request = %Q(
      <?xml version="1.0" encoding="utf-8"?>
      <GetUserRequest xmlns="urn:ebay:apis:eBLBaseComponents">
        <RequesterCredentials>
          <eBayAuthToken>#{auth_token}</eBayAuthToken>
        </RequesterCredentials>
      </GetUserRequest>
    )

    response = api(X_EBAY_API_GETUSER_CALL_NAME, request)
    MultiXml.parse(response)["GetUserResponse"]['User']
  end

  def ebay_login_url(session_id)

    url = "#{options.loginurl}?SingleSignOn&runame=#{options.runame}&sid=#{URI.escape(session_id)}"

    redirect_url = request.params['redirect_url'] || request.params[:redirect_url]
    url << "&ruparams=#{URI.escape('redirect_url=' + redirect_url)}" if redirect_url

    url
  end

  protected

  def api(call_name, request)
    headers = ebay_request_headers(call_name, request.length.to_s)
    url = URI.parse(options.apiurl)
    req = Net::HTTP::Post.new(url.path, headers)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.start { |h| h.request(req, request) }.body
  end

  def ebay_request_headers(call_name, request_length)
    {
        'X-EBAY-API-CALL-NAME'  => call_name,
        'X-EBAY-API-COMPATIBILITY-LEVEL'  => X_EBAY_API_COMPATIBILITY_LEVEL,
        'X-EBAY-API-DEV-NAME' => options.devid,
        'X-EBAY-API-APP-NAME' => options.appid,
        'X-EBAY-API-CERT-NAME' => options.certid,
        'X-EBAY-API-SITEID' => options.siteid.to_s,
        'Content-Type' => X_EBAY_API_REQUEST_CONTENT_TYPE,
        'Content-Length' => request_length
    }
  end
end
