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

      result = pay_get(uri)
      result
    end

    # Search payment information using status.
    # default items per page: 20
    # https://api.iamport.kr/#!/payments/getPaymentsByStatus
    def payments(options = {})
      status = options[:status] || "all"
      page = options[:page] || 1

      uri = "payments/status/#{status}?page=#{page}"

      result = pay_get(uri)
      result
    end

    # Canceled payments
    # https://api.iamport.kr/#!/payments/cancelPayment
    def cancel(body)
      uri = "payments/cancel"

      result = pay_post(uri, body)
      result
    end

    private

    # Get header data
    def get_headers
      { Authorization: token }
    end

    # GET
    def pay_get(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"

      response = HTTParty.get url, headers: get_headers, body: payload
      response["response"]
    end

    # POST
    def pay_post(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"

      response = HTTParty.post url, headers: get_headers, body: payload
      response["response"]
    end
  end
end
