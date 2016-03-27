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
      url = "#{IAMPORT_HOST}/payments/cancel?_token=#{token}"

      result = HTTParty.post url, body: body
      result
    end
  end
end
