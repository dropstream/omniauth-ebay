require 'omniauth'

module OmniAuth
  module Strategies
    class Ebay
      include OmniAuth::Strategy
      include EbayAPI

      args [:runame, :devid, :appid, :certid, :siteid, :is_sandbox]
      option :name, 'ebay'
      option :runame, nil
      option :devid, nil
      option :appid, nil
      option :certid, nil
      option :siteid, '0'
      option :is_sandbox, true


      uid do
        raw_info.nil? ? {} : raw_info['UserID']
      end
      
      info do
        raw_info.nil? ? {} :
        {
            user_id: raw_info['UserID'],
            auth_token: @auth_token,
            email: raw_info['Email'],
            full_name: raw_info['RegistrationAddress'].try(:[], 'Name'),
            eias_token: raw_info['EIASToken']
        }
      end

      #1: We'll get to the request_phase by accessing /auth/ebay
      #2: Request from eBay a SessionID
      #3: Redirect to eBay Login URL with the RUName and SessionID
      def request_phase
        redirect ebay_login_url(session['omniauth.ebay.session_id'] = get_session_id(options.runame))
      end

      #4: We'll get to the callback phase by setting our accept/reject URL in the ebay application settings(/auth/ebay/callback)
      #5: Request an eBay Auth Token with the returned username&secret_id parameters.
      #6: Request the user info from eBay
      def callback_phase
        @user_info = get_user(@auth_token = fetch_auth_token(session['omniauth.ebay.session_id']))
        super
      end

      def raw_info
        @user_info
      end
    end
  end
end

OmniAuth.config.add_camelization 'ebay', 'Ebay'
