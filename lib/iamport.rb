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
    # POST /users/getToken
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

    # ============================================================
    # Payments
    # ============================================================

    # Get payment information using imp_uid
    # GET /payments/{imp_uid}
    def payment(imp_uid)
      uri = "payments/#{imp_uid}"

      pay_get(uri)
    end

    # Get multiple payments by imp_uid[]
    # GET /payments
    def payments_by_imp_uid(imp_uid_list = [])
      uri = "payments?" + imp_uid_list.map { |uid| "imp_uid[]=#{uid}" }.join("&")

      pay_get(uri)
    end

    # Search payment information using status.
    # default items per page: 20
    # GET /payments/status/{payment_status}
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
    # GET /payments/find/{merchant_uid}/{payment_status}
    def find(merchant_uid, payment_status = nil)
      uri = "payments/find/#{CGI.escape(merchant_uid)}"
      uri += "/#{payment_status}" if payment_status

      pay_get(uri)
    end

    # Find all payments by merchant_uid (including duplicates)
    # GET /payments/findAll/{merchant_uid}/{payment_status}
    def find_all(merchant_uid, payment_status = nil)
      uri = "payments/findAll/#{CGI.escape(merchant_uid)}"
      uri += "/#{payment_status}" if payment_status

      pay_get(uri)
    end

    # Get payment balance detail
    # GET /payments/{imp_uid}/balance
    def payment_balance(imp_uid)
      uri = "payments/#{imp_uid}/balance"

      pay_get(uri)
    end

    # Prepare payment validation (create)
    # POST /payments/prepare
    def prepare(body)
      uri = "payments/prepare"

      pay_post(uri, body)
    end

    # Update prepared payment validation
    # PUT /payments/prepare
    def update_prepare(body)
      uri = "payments/prepare"

      pay_put(uri, body)
    end

    # Get prepared payment information by merchant_uid
    # GET /payments/prepare/{merchant_uid}
    def prepared(merchant_uid)
      uri = "payments/prepare/#{CGI.escape(merchant_uid)}"

      pay_get(uri)
    end

    # Canceled payments
    # POST /payments/cancel
    def cancel(body)
      uri = "payments/cancel"

      pay_post(uri, body)
    end

    # ============================================================
    # Certifications
    # ============================================================

    # Get certification info
    # GET /certifications/{imp_uid}
    def get_certificate(imp_uid)
      uri = "certifications/#{imp_uid}"

      pay_get(uri)
    end

    # Delete certification info
    # DELETE /certifications/{imp_uid}
    def delete_certificate(imp_uid)
      uri = "certifications/#{imp_uid}"

      pay_delete(uri)
    end

    # Request OTP for identity verification
    # POST /certifications/otp/request
    def request_otp(body)
      uri = "certifications/otp/request"

      pay_post(uri, body)
    end

    # Confirm OTP for identity verification
    # POST /certifications/otp/confirm/{imp_uid}
    def confirm_otp(imp_uid, body)
      uri = "certifications/otp/confirm/#{imp_uid}"

      pay_post(uri, body)
    end

    # ============================================================
    # Escrows
    # ============================================================

    # Get escrow logistics info
    # GET /escrows/logis/{imp_uid}
    def get_escrow_logis(imp_uid)
      uri = "escrows/logis/#{imp_uid}"

      pay_get(uri)
    end

    # Create escrow logistics info
    # POST /escrows/logis/{imp_uid}
    def create_escrow_logis(imp_uid, body)
      uri = "escrows/logis/#{imp_uid}"

      pay_post(uri, body)
    end

    # Update escrow logistics info
    # PUT /escrows/logis/{imp_uid}
    def update_escrow_logis(imp_uid, body)
      uri = "escrows/logis/#{imp_uid}"

      pay_put(uri, body)
    end

    # ============================================================
    # Subscribe - Customers (Billing Key)
    # ============================================================

    # Get multiple customers billing key info
    # GET /subscribe/customers
    def customers(customer_uid_list = [])
      uri = "subscribe/customers?" + customer_uid_list.map { |uid| "customer_uid[]=#{uid}" }.join("&")

      pay_get(uri)
    end

    # Create and Delete a billing key by customer_uid
    # DELETE /subscribe/customers/{customer_uid}
    # GET /subscribe/customers/{customer_uid}
    { customer: :get, delete_customer: :delete }.each do |method_name, type|
      define_method(method_name) do |customer_uid|
        uri = "subscribe/customers/#{CGI.escape(customer_uid)}"

        send("pay_#{type}", uri)
      end
    end

    # Create/Update customer billing key
    # POST /subscribe/customers/{customer_uid}
    def create_customer(customer_uid, payload = {})
      uri = "subscribe/customers/#{CGI.escape(customer_uid)}"

      pay_post(uri, payload)
    end

    # Get customer payments
    # GET /subscribe/customers/{customer_uid}/payments
    def customer_payments(customer_uid)
      uri = "subscribe/customers/#{CGI.escape(customer_uid)}/payments"

      pay_get(uri)
    end

    # Get customer schedules
    # GET /subscribe/customers/{customer_uid}/schedules
    def customer_schedules(customer_uid)
      uri = "subscribe/customers/#{CGI.escape(customer_uid)}/schedules"

      pay_get(uri)
    end

    # ============================================================
    # Subscribe - Payments
    # ============================================================

    # Create onetime payment
    # POST /subscribe/payments/onetime
    def create_onetime_payment(payload = {})
      uri = "subscribe/payments/onetime"

      pay_post(uri, payload)
    end

    # Create payment again
    # POST /subscribe/payments/again
    def create_payment_again(payload = {})
      uri = "subscribe/payments/again"

      pay_post(uri, payload)
    end

    # Schedule payments
    # POST /subscribe/payments/schedule
    def schedule_payments(payload)
      uri = "subscribe/payments/schedule"

      pay_post(uri, payload)
    end

    # Unschedule payments
    # POST /subscribe/payments/unschedule
    def unschedule_payments(payload)
      uri = "subscribe/payments/unschedule"

      pay_post(uri, payload)
    end

    # Get schedule by merchant_uid
    # GET /subscribe/payments/schedule/{merchant_uid}
    def schedule_merchant_uid(merchant_uid)
      uri = "subscribe/payments/schedule/#{CGI.escape(merchant_uid)}"

      pay_get(uri)
    end

    # Update schedule by merchant_uid
    # PUT /subscribe/payments/schedule/{merchant_uid}
    def update_schedule(merchant_uid, body)
      uri = "subscribe/payments/schedule/#{CGI.escape(merchant_uid)}"

      pay_put(uri, body)
    end

    # Retry failed scheduled payment
    # POST /subscribe/payments/schedule/{merchant_uid}/retry
    def retry_schedule(merchant_uid, body = {})
      uri = "subscribe/payments/schedule/#{CGI.escape(merchant_uid)}/retry"

      pay_post(uri, body)
    end

    # Reschedule failed payment
    # POST /subscribe/payments/schedule/{merchant_uid}/reschedule
    def reschedule(merchant_uid, body = {})
      uri = "subscribe/payments/schedule/#{CGI.escape(merchant_uid)}/reschedule"

      pay_post(uri, body)
    end

    # Get schedules by customer_uid
    # GET /subscribe/payments/schedule/customers/{customer_uid}
    def schedule_customer_uid(customer_uid:, from:, to:, page: nil, schedule_status: nil)
      uri = "subscribe/payments/schedule/customers/#{CGI.escape(customer_uid)}"

      uri += "?from=#{from.to_i}"
      uri += "&to=#{to.to_i}"

      uri += "&page=#{page}" if page
      uri += "&schedule_status=#{schedule_status}" if schedule_status

      pay_get(uri)
    end

    # Get all schedules by date range
    # GET /subscribe/payments/schedule
    def schedules(options = {})
      uri = "subscribe/payments/schedule?"
      uri += "from=#{options[:from].to_i}" if options[:from]
      uri += "&to=#{options[:to].to_i}" if options[:to]
      uri += "&page=#{options[:page]}" if options[:page]
      uri += "&schedule_status=#{options[:schedule_status]}" if options[:schedule_status]

      pay_get(uri)
    end

    # ============================================================
    # Virtual Banks (VBanks)
    # ============================================================

    # Create virtual bank
    # POST /vbanks
    def create_vbank(body)
      uri = "vbanks"

      pay_post(uri, body)
    end

    # Update virtual bank
    # PUT /vbanks/{imp_uid}
    def update_vbank(imp_uid, body)
      uri = "vbanks/#{imp_uid}"

      pay_put(uri, body)
    end

    # Delete virtual bank
    # DELETE /vbanks/{imp_uid}
    def delete_vbank(imp_uid)
      uri = "vbanks/#{imp_uid}"

      pay_delete(uri)
    end

    # Check bank account holder
    # GET /vbanks/holder
    def check_holder(options = {})
      bank_code = options[:bank_code]
      bank_num = options[:bank_num]

      uri = "vbanks/holder?bank_code=#{bank_code}&bank_num=#{bank_num}"

      pay_get(uri)
    end

    # ============================================================
    # Receipts
    # ============================================================

    # Get receipt
    # GET /receipts/{imp_uid}
    def get_receipt(imp_uid)
      uri = "receipts/#{imp_uid}"

      pay_get(uri)
    end

    # Create receipt
    # POST /receipts/{imp_uid}
    def create_receipt(imp_uid, body)
      uri = "receipts/#{imp_uid}"

      pay_post(uri, body)
    end

    # Delete receipt
    # DELETE /receipts/{imp_uid}
    def delete_receipt(imp_uid)
      uri = "receipts/#{imp_uid}"

      pay_delete(uri)
    end

    # Get external receipt
    # GET /receipts/external/{merchant_uid}
    def get_external_receipt(merchant_uid)
      uri = "receipts/external/#{CGI.escape(merchant_uid)}"

      pay_get(uri)
    end

    # Create external receipt
    # POST /receipts/external/{merchant_uid}
    def create_external_receipt(merchant_uid, body)
      uri = "receipts/external/#{CGI.escape(merchant_uid)}"

      pay_post(uri, body)
    end

    # Delete external receipt
    # DELETE /receipts/external/{merchant_uid}
    def delete_external_receipt(merchant_uid)
      uri = "receipts/external/#{CGI.escape(merchant_uid)}"

      pay_delete(uri)
    end

    # ============================================================
    # Codes (Banks & Cards)
    # ============================================================

    # Get all bank codes
    # GET /banks
    def bank_codes
      uri = "banks"

      pay_get(uri)
    end

    # Get bank name by code
    # GET /banks/{bank_standard_code}
    def bank_code(bank_standard_code)
      uri = "banks/#{bank_standard_code}"

      pay_get(uri)
    end

    # Get all card codes
    # GET /cards
    def card_codes
      uri = "cards"

      pay_get(uri)
    end

    # Get card name by code
    # GET /cards/{card_standard_code}
    def card_code(card_standard_code)
      uri = "cards/#{card_standard_code}"

      pay_get(uri)
    end

    # ============================================================
    # Benepia
    # ============================================================

    # Query Benepia point
    # POST /benepia/point
    def benepia_point(body)
      uri = "benepia/point"

      pay_post(uri, body)
    end

    # Pay with Benepia point
    # POST /benepia/payment
    def benepia_payment(body)
      uri = "benepia/payment"

      pay_post(uri, body)
    end

    # ============================================================
    # CVS (Convenience Store Payment)
    # ============================================================

    # Issue CVS payment
    # POST /cvs
    def create_cvs(body)
      uri = "cvs"

      pay_post(uri, body)
    end

    # Revoke CVS payment
    # DELETE /cvs/{imp_uid}
    def delete_cvs(imp_uid)
      uri = "cvs/#{imp_uid}"

      pay_delete(uri)
    end

    # ============================================================
    # KCP Quick Pay
    # ============================================================

    # Pay with KCP quick pay money
    # POST /kcpquick/payment/money
    def kcpquick_payment(body)
      uri = "kcpquick/payment/money"

      pay_post(uri, body)
    end

    # Delete KCP quick pay member
    # DELETE /kcpquick/members/{member_id}
    def delete_kcpquick_member(member_id)
      uri = "kcpquick/members/#{member_id}"

      pay_delete(uri)
    end

    # ============================================================
    # Naver Pay
    # ============================================================

    # Get single Naver product order
    # GET /naver/product-orders/{product_order_id}
    def naver_product_order(product_order_id)
      uri = "naver/product-orders/#{product_order_id}"

      pay_get(uri)
    end

    # Get Naver reviews
    # GET /naver/reviews
    def naver_reviews
      uri = "naver/reviews"

      pay_get(uri)
    end

    # Get Naver product orders by imp_uid
    # GET /payments/{imp_uid}/naver/product-orders
    def naver_product_orders(imp_uid)
      uri = "payments/#{imp_uid}/naver/product-orders"

      pay_get(uri)
    end

    # Get Naver cash amount
    # GET /payments/{imp_uid}/naver/cash-amount
    def naver_cash_amount(imp_uid)
      uri = "payments/#{imp_uid}/naver/cash-amount"

      pay_get(uri)
    end

    # Naver place product order
    # POST /payments/{imp_uid}/naver/place
    def naver_place(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/place"

      pay_post(uri, body)
    end

    # Naver ship product order
    # POST /payments/{imp_uid}/naver/ship
    def naver_ship(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/ship"

      pay_post(uri, body)
    end

    # Naver ship exchanged product order
    # POST /payments/{imp_uid}/naver/ship-exchanged
    def naver_ship_exchanged(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/ship-exchanged"

      pay_post(uri, body)
    end

    # Naver cancel product order
    # POST /payments/{imp_uid}/naver/cancel
    def naver_cancel(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/cancel"

      pay_post(uri, body)
    end

    # Naver approve cancel product order
    # POST /payments/{imp_uid}/naver/approve-cancel
    def naver_approve_cancel(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/approve-cancel"

      pay_post(uri, body)
    end

    # Naver request return product order
    # POST /payments/{imp_uid}/naver/request-return
    def naver_request_return(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/request-return"

      pay_post(uri, body)
    end

    # Naver approve return product order
    # POST /payments/{imp_uid}/naver/approve-return
    def naver_approve_return(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/approve-return"

      pay_post(uri, body)
    end

    # Naver reject return product order
    # POST /payments/{imp_uid}/naver/reject-return
    def naver_reject_return(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/reject-return"

      pay_post(uri, body)
    end

    # Naver withhold return product order
    # POST /payments/{imp_uid}/naver/withhold-return
    def naver_withhold_return(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/withhold-return"

      pay_post(uri, body)
    end

    # Naver resolve return product order
    # POST /payments/{imp_uid}/naver/resolve-return
    def naver_resolve_return(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/resolve-return"

      pay_post(uri, body)
    end

    # Naver collect exchanged product order
    # POST /payments/{imp_uid}/naver/collect-exchanged
    def naver_collect_exchanged(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/collect-exchanged"

      pay_post(uri, body)
    end

    # Naver confirm payment (escrow)
    # POST /payments/{imp_uid}/naver/confirm
    def naver_confirm(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/confirm"

      pay_post(uri, body)
    end

    # Naver deposit point
    # POST /payments/{imp_uid}/naver/point
    def naver_point(imp_uid, body = {})
      uri = "payments/#{imp_uid}/naver/point"

      pay_post(uri, body)
    end

    # ============================================================
    # Partners
    # ============================================================

    # Register partner receipt
    # POST /partners/receipts/{imp_uid}
    def create_partner_receipt(imp_uid, body)
      uri = "partners/receipts/#{imp_uid}"

      pay_post(uri, body)
    end

    # ============================================================
    # Payco
    # ============================================================

    # Change Payco order status
    # POST /payco/orders/status/{imp_uid}
    def payco_order_status(imp_uid, body)
      uri = "payco/orders/status/#{imp_uid}"

      pay_post(uri, body)
    end

    # ============================================================
    # Paymentwall
    # ============================================================

    # Register Paymentwall delivery
    # POST /paymentwall/delivery
    def paymentwall_delivery(body)
      uri = "paymentwall/delivery"

      pay_post(uri, body)
    end

    # ============================================================
    # Tiers
    # ============================================================

    # Get tier info
    # GET /tiers/{tier_code}
    def tier(tier_code)
      uri = "tiers/#{tier_code}"

      pay_get(uri)
    end

    # ============================================================
    # Users
    # ============================================================

    # Get PG setting list
    # GET /users/pg
    def pg_settings
      uri = "users/pg"

      pay_get(uri)
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

    # PUT
    def pay_put(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"
      HTTParty.put(url, headers: headers.merge('Content-Type' => 'application/json'), body: payload.to_json)
    end

    # DELETE
    def pay_delete(uri, payload = {})
      url = "#{IAMPORT_HOST}/#{uri}"
      HTTParty.delete(url, headers: headers, body: payload)
    end
  end
end
