require "iamport/version"

module Iamport
  IAMPORT_HOST = "api.iamport.kr:443"

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
      url = "https://#{IAMPORT_HOST}/users/getToken"
      result = HTTParty.post url, body: { imp_key: config.api_key, imp_secret: config.api_secret }
      result["response"]["access_token"]
    end

    def payment(imp_uid)
      url = "https://#{IAMPORT_HOST}/payments/#{imp_uid}?_token=#{token}"
      result = HTTParty.post url
      result["response"]
    end

    def payments(options = {})
      status = options[:status] || "all"
      page = options[:page] || 1

      url = "https://#{IAMPORT_HOST}/payments/status/#{status}?_token=#{token}&page=#{page}"
      result = HTTParty.post url
      result["response"]
    end
  end
end
