require "iamport/version"

module Iamport
  IAMPORT_HOST = "https://api.iamport.kr"

  class Config
    attr_accessor :api_key
    attr_accessor :api_secret
  end

  class << self
    def configure
      yield(config) if block_given?
    end

    def config
      @config ||= Config.new
    end

    # Get Token
    # https://api.iamport.kr/#!/authenticate/getToken
    def token
      url = "#{IAMPORT_HOST}/users/getToken"
      body = {
          imp_key: config.api_key,
          imp_secret: config.api_secret
      }

      result = HTTParty.post url, body: body
      result["response"]["access_token"]
    end

    # Get payment information using imp_uid
    # https://api.iamport.kr/#!/payments/getPaymentByImpUid
    def payment(imp_uid)
      uri = "payments/#{imp_uid}"

      _get(uri)
    end

    # Search payment information using status.
    # default items per page: 20
    # https://api.iamport.kr/#!/payments/getPaymentsByStatus
    def payments(options = {})
      status = options[:status] || "all"
      page = options[:page] || 1

      uri = "payments/status/#{status}?page=#{page}"

      _get(uri)
    end

    # Find payment information using merchant uid
    # https://api.iamport.kr/#!/payments/getPaymentByMerchantUid
    def find(merchant_uid)
      uri = "payments/find/#{merchant_uid}"

      _get(uri)
    end

    # Canceled payments
    # https://api.iamport.kr/#!/payments/cancelPayment
    def cancel(body)
      uri = "payments/cancel"

      _post(uri, body)
    end

    # Get a billing key by customer_uid
    # GET https://api.iamport.kr/#!/subscribe/customers/:customer_uid
    def find_subscribe_customer(customer_uid)
      uri = "subscribe/customers/#{customer_uid}"

      _get(uri)
    end
    
    # Create (or update if exists) a billing key by customer_uid
    # POST https://api.iamport.kr/#!/subscribe/customers/:customer_uid
    def create_subscribe_customer(customer_uid, body)
      uri = "subscribe/customers/#{customer_uid}"

      _post(uri, body)
    end

    # Delete a billing key by customer_uid
    # DELETE https://api.iamport.kr/#!/subscribe/customers/:customer_uid
    def delete_subscribe_customer(customer_uid)
      uri = "subscribe/customers/#{customer_uid}"

      _delete(uri)
    end

    private

    # Get header data
    def get_headers
      { "Authorization" => token }
    end

    # GET
    def _get(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"

      HTTParty.get url, headers: get_headers, body: payload
    end

    # POST
    def _post(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"

      HTTParty.post url, headers: get_headers, body: payload
    end

    # DELETE
    def _delete(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"

      HTTParty.delete url, headers: get_headers, body: payload
    end

  end
end
