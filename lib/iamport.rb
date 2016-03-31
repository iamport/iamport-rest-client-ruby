require "iamport/version"

module Iamport
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

    def token
      url = "#{IAMPORT_HOST}/users/getToken"
      body = {
        imp_key: config.api_key,
        imp_secret: config.api_secret
      }

      result = HTTParty.post url, body: body
      result["response"]["access_token"]
    end

    def payment(imp_uid)
      url = "#{IAMPORT_HOST}/payments/#{imp_uid}?_token=#{token}"

      result = HTTParty.post url
      result["response"]
    end

    def payments(options = {})
      status = options[:status] || "all"
      page = options[:page] || 1

      url = "#{IAMPORT_HOST}/payments/status/#{status}?_token=#{token}&page=#{page}"

      result = HTTParty.post url
      result["response"]
    end

    def cancel(body)
      url = '/payments/cancel'

      result = pay_post(url, body)
      result
    end

    private

    $iamport_host = 'https://api.iamport.kr'

    def get_headers
      { Authorization: token }
    end

    def pay_get(uri, payload = {})
      url = $iamport_host + uri

      response = HTTParty.post url, headers: get_headers, body: payload
      get_response(response)
    end

    def pay_post(uri, payload = {})
      url = $iamport_host + uri

      response = HTTParty.post url, headers: get_headers, body: payload
      get_response(response)
    end

    def get_response(response)
      if response['code'] != 0
        result = { code: response['code'], message: response['message'] }
        return result
      end

      response['response']
    end
  end
end
