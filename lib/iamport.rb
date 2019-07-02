require "iamport/version"
require "httparty"

module Iamport
  IAMPORT_HOST = "https://api.iamport.kr".freeze

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
        imp_secret: config.api_secret,
      }

      result = HTTParty.post url, body: body

      raise "Invalid Token" unless result["response"]
      result["response"]["access_token"]
    end

    # Get payment information using imp_uid
    # https://api.iamport.kr/#!/payments/getPaymentByImpUid
    def payment(imp_uid)
      uri = "payments/#{imp_uid}"

      pay_get(uri)
    end

    # Search payment information using status.
    # default items per page: 20
    # https://api.iamport.kr/#!/payments/getPaymentsByStatus
    def payments(options = {})
      status = options[:status] || "all"
      page = options[:page] || 1
      from = options[:from]
      to = options[:to]
      
      uri = "payments/status/#{status}?page=#{page}"
      uri += "&from=#{from}" if from
      uri += "&to=#{to}" if to

      pay_get(uri)
    end

    # Find payment information using merchant uid
    # https://api.iamport.kr/#!/payments/getPaymentByMerchantUid
    def find(merchant_uid)
      uri = "payments/find/#{merchant_uid}"

      pay_get(uri)
    end

    # Prepare payment validation
    # https://api.iamport.kr/#!/payments/prepare
    def prepare(body)
      uri = "payments/prepare"

      pay_post(uri, body)
    end

    # Get prepared payment information by merchant_uid
    # https://api.iamport.kr/#!/payments/prepare/:merchant_uid
    def prepared(merchant_uid)
      uri = "payments/prepare/#{merchant_uid}"

      pay_get(uri)
    end

    # Canceled payments
    # https://api.iamport.kr/#!/payments/cancelPayment
    def cancel(body)
      uri = "payments/cancel"

      pay_post(uri, body)
    end

    # create onetime
    # POST https://api.iamport.kr/#!/subscribe/payments/onetime
    def create_onetime_payment(payload = {})
      uri = "subscribe/payments/onetime"

      pay_post(uri, payload)
    end

    # create payment again
    # POST https://api.iamport.kr/#!/subscribe/payments/again
    def create_payment_again(payload = {})
      uri = "subscribe/payments/again"

      pay_post(uri, payload)
    end

    # (un)schedule payments
    # POST https://api.iamport.kr/#!/subscribe/schedule
    %i(schedule unschedule).each do |method_name|
      define_method("#{method_name}_payments") do |payload|
        uri = "/subscribe/payments/#{method_name}"

        pay_post(uri, payload)
      end
    end

    # Create and Delete a billing key by customer_uid
    # DELETE https://api.iamport.kr/#!/subscribe/customers/:customer_uid
    # GET https://api.iamport.kr/#!/subscribe/customers/:customer_uid
    { customer: :get, delete_customer: :delete }.each do |method_name, type|
      define_method(method_name) do |customer_uid|
        uri = "subscribe/customers/#{customer_uid}"

        send("pay_#{type}", uri)
      end
    end

    def create_customer(customer_uid, payload = {})
      uri = "subscribe/customers/#{customer_uid}"

      pay_post(uri, payload)
    end

    def customer_payments(customer_uid)
      uri = "subscribe/customers/#{customer_uid}/payments"

      pay_get(uri)
    end
    
    def create_vbank(body)
      uri = "/vbanks"

      pay_post(uri, body)
    end
    
    def delete_vbank(imp_uid)
      uri = "vbanks/#{imp_uid}"
      
      pay_delete(uri)
    end
    
    def check_holder(options = {})
      bank_code = options[:bank_code]
      bank_num = options[:bank_num]

      uri = "vbanks/holder?bank_code=#{bank_code}&bank_num=#{bank_num}"
      
      pay_get(uri)
    end
    
    def get_receipt(imp_uid)
      uri = "receipts/#{imp_uid}"
      
      pay_get(uri)
    end
    
    def create_receipt(imp_uid, body)
      uri = "receipts/#{imp_uid}"
      
      pay_post(uri, body)
    end

    def delete_receipt(imp_uid)
      uri = "receipts/#{imp_uid}"
      
      pay_delete(uri)
    end

    def delete_external_receipt(merchant_uid)
      uri = "receipts/#{merchant_uid}"
      
      pay_delete(uri)
    end

    private

    # Get header data
    def headers
      { "Authorization" => token }
    end

    # GET
    def pay_get(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"
      HTTParty.get(url, headers: headers, body: payload)
    end

    # POST
    def pay_post(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"
      HTTParty.post(url, headers: headers.merge('Content-Type' => 'application/json'), body: payload.to_json)
    end

    # DELETE
    def pay_delete(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"
      HTTParty.delete(url, headers: headers, body: payload)
    end
  end
end
