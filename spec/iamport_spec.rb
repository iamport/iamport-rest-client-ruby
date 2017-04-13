require "spec_helper"
require "httparty"
require "pry"

API_KEY = "xxxxxxx".freeze
API_SECRET = "xxxxxx".freeze
IMP_UID = "xxxxxxx".freeze
MERCHANT_UID = "M00001".freeze

describe Iamport, "::VERSION" do
  it "has a version number" do
    expect(Iamport::VERSION).not_to be nil
  end
end

describe Iamport, ".configure" do
  it "sets configuration" do
    Iamport.configure do |config|
      config.api_key = API_KEY
      config.api_secret = API_SECRET
    end
    expect(Iamport.config.api_key).to eq(API_KEY)
    expect(Iamport.config.api_secret).to eq(API_SECRET)
  end
end

describe Iamport do
  IAMPORT_HOST = "https://api.iamport.kr".freeze

  before do
    Iamport.configure do |config|
      config.api_key = API_KEY
      config.api_secret = API_SECRET
    end
  end

  describe ".token" do
    it "generates and returns new token" do
      expected_url = "#{IAMPORT_HOST}/users/getToken"
      expected_params = {
        body: {
          imp_key: API_KEY,
          imp_secret: API_SECRET,
        },
      }

      response = {
        "response" => {
          "access_token" => "NEW_TOKEN",
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      expect(Iamport.token).to eq("NEW_TOKEN")
    end
  end

  let(:payment_json) do
    {
      "amount" => 10_000,
      "apply_num" => "00000000",
      "buyer_addr" => "서울 송파구 잠실동",
      "buyer_email" => "test@email.com",
      "buyer_name" => "홍길동",
      "buyer_postcode" => nil,
      "buyer_tel" => "01000000001",
      "cancel_amount" => "0",
      "cancel_reason" => nil,
      "cancelled_at" => 0,
      "card_name" => "하나SK 카드",
      "card_quota" => 0,
      "custom_data" => nil,
      "fail_reason" => nil,
      "failed_at" => 0,
      "IMP_UID" => IMP_UID,
      "merchant_uid" => MERCHANT_UID,
      "name" => "제품이름",
      "paid_at" => 1_111,
      "pay_method" => "card",
      "pg_provider" => "nice",
      "pg_tid" => "w00000000000000000000000000001",
      "receipt_url" => "RECEIPT_URL",
      "status" => "paid",
      "user_agent" => "Mozilla/5.0",
      "vbank_date" => 0,
      "vbank_holder" => nil,
      "vbank_name" => nil,
      "vbank_num" => nil,
    }
  end

  let(:customer_uid) { "8" }

  let(:one_time_response) do
    {
      "code" => 0,
      "message" => "string",
      "response" => {
        "imp_uid" => IMP_UID,
        "merchant_uid" => MERCHANT_UID,
        "pay_method" => "string",
        "pg_provider" => "string",
        "pg_tid" => "string",
        "escrow" => true,
        "apply_num" => "string",
        "bank_name" => "string",
        "card_name" => "string",
        "card_quota" => 0,
        "vbank_name" => "string",
        "vbank_num" => "string",
        "vbank_holder" => "string",
        "vbank_date" => 0,
        "name" => "string",
        "amount" => 0,
        "cancel_amount" => 0,
        "currency" => "string",
        "buyer_name" => "string",
        "buyer_email" => "string",
        "buyer_tel" => "string",
        "buyer_addr" => "string",
        "buyer_postcode" => "string",
        "custom_data" => "string",
        "user_agent" => "string",
        "status" => "ready",
        "paid_at" => 0,
        "failed_at" => 0,
        "cancelled_at" => 0,
        "fail_reason" => "string",
        "cancel_reason" => "string",
        "receipt_url" => "string",
      },
    }
  end

  let(:customer_response) do
    {
      "code" => 0,
      "message" => "string",
      "response" => {
        "customer_uid" => customer_uid,
        "card_name" => "string",
        "customer_name" => "string",
        "customer_tel" => "string",
        "customer_email" => "string",
        "customer_addr" => "string",
        "customer_postcode" => "string",
        "inserted" => 0,
        "updated" => 0,
      },
    }
  end

  let(:payment_again_response) do
    {
      "code" => 0,
      "message" => "string",
      "response" =>
      {
        "imp_uid" => IMP_UID,
        "merchant_uid" => MERCHANT_UID,
        "pay_method" => "string",
        "pg_provider" => "string",
        "pg_tid" => "string",
        "escrow" => true,
        "apply_num" => "string",
        "bank_name" => "string",
        "card_name" => "string",
        "card_quota" => 0,
        "vbank_name" => "string",
        "vbank_num" => "string",
        "vbank_holder" => "string",
        "vbank_date" => 0,
        "name" => "string",
        "amount" => 0,
        "cancel_amount" => 0,
        "currency" => "string",
        "buyer_name" => "string",
        "buyer_email" => "string",
        "buyer_tel" => "string",
        "buyer_addr" => "string",
        "buyer_postcode" => "string",
        "custom_data" => "string",
        "user_agent" => "string",
        "status" => "ready",
        "paid_at" => 0,
        "failed_at" => 0,
        "cancelled_at" => 0,
        "fail_reason" => "string",
        "cancel_reason" => "string",
        "receipt_url" => "string",
        "cancel_history" => [
          {
            "pg_tid" => "string",
            "amount" => 0,
            "cancelled_at" => 0,
            "reason" => "string",
            "receipt_url" => "string",
          },
        ],
        "cancel_receipt_urls" => [
          "string",
        ],
      },
    }
  end

  let(:customer_payment_response) do
    {
      "code" => 0,
      "message" => "string",
      "response" => {
        "total" => 1,
        "previous" => 0,
        "next" => 0,
        "list" => [
          {
            "imp_uid" => IMP_UID,
            "merchant_uid" => MERCHANT_UID,
            "pay_method" => "string",
            "pg_provider" => "string",
            "pg_tid" => "string",
            "escrow" => true,
            "apply_num" => "string",
            "bank_name" => "string",
            "card_name" => "string",
            "card_quota" => 0,
            "vbank_name" => "string",
            "vbank_num" => "string",
            "vbank_holder" => "string",
            "vbank_date" => 0,
            "name" => "string",
            "amount" => 0,
            "cancel_amount" => 0,
            "currency" => "string",
            "buyer_name" => "string",
            "buyer_email" => "string",
            "buyer_tel" => "string",
            "buyer_addr" => "string",
            "buyer_postcode" => "string",
            "custom_data" => "string",
            "user_agent" => "string",
            "status" => "ready",
            "paid_at" => 0,
            "failed_at" => 0,
            "cancelled_at" => 0,
            "fail_reason" => "string",
            "cancel_reason" => "string",
            "receipt_url" => "string",
            "cancel_history" => [
              {
                "pg_tid" => "string",
                "amount" => 0,
                "cancelled_at" => 0,
                "reason" => "string",
                "receipt_url" => "string",
              },
            ],
            "cancel_receipt_urls" => [
              "string",
            ],
          },
        ],
      },
    }
  end

  describe "payment" do
    it "returns payment info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{IMP_UID}"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)

      res = Iamport.payment(IMP_UID)
      expect(res["response"]["IMP_UID"]).to eq(IMP_UID)
    end
  end

  describe "payments" do
    it "returns payment list" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/status/all?page=1"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => {
          "total" => 150,
          "previous" => false,
          "next" => 2,
          "list" => [
            payment_json,
            payment_json,
          ],
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)
      res = Iamport.payments
      expect(res["response"]["total"]).to eq(150)
      expect(res["response"]["list"].size).to eq(2)
    end
  end

  describe "subscribe" do
    it "payment onetime" do
      one_time_url = "#{IAMPORT_HOST}/subscribe/payments/onetime"

      payload = {
        merchant_uid: "xxxxx",
        amount: 11_111,
        card_number: "dddd-dddd-dddd-ddddd",
        expiry: "yyy-mm",
        birth: "dddddd",
      }

      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: payload,
      }

      response = {
        "response" => one_time_response,
      }

      expect(HTTParty).to receive(:post).with(one_time_url, expected_params).and_return(response)
      body = expected_params[:body]
      res = Iamport.onetime(body)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["imp_uid"]).to eq(IMP_UID)
    end

    it "payment again" do
      payment_again_url = "#{IAMPORT_HOST}/subscribe/payments/again"
      payload = {
        customer_uid: "xxxxx",
        merchant_uid: "xxxxx",
        amount: 1,
        name: "tester",
      }
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: payload,
      }
      response = {
        "response" => payment_again_response,
      }

      expect(HTTParty).to receive(:post).with(payment_again_url, expected_params)
        .and_return(response)
      body = expected_params[:body]
      res = Iamport.again(body)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["merchant_uid"]).to eq(MERCHANT_UID)
    end

    it "create_customer" do
      customer_url = sprintf("%s/subscribe/customers/%s", IAMPORT_HOST, customer_uid)
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => customer_response,
      }

      expect(HTTParty).to receive(:post).with(customer_url, expected_params)
        .and_return(response)
      res = Iamport.create_customer(customer_uid)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["response"]["customer_uid"]).to be_a_kind_of(String)
    end

    it "get_customer" do
      customer_url = sprintf("%s/subscribe/customers/%s", IAMPORT_HOST, customer_uid)
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => customer_response,
      }

      expect(HTTParty).to receive(:get).with(customer_url, expected_params)
        .and_return(response)
      res = Iamport.customer(customer_uid)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["response"]["customer_uid"]).to be_a_kind_of(String)
    end

    it "delete_customer" do
      delete_customer_url = sprintf("%s/subscribe/customers/%s", IAMPORT_HOST, customer_uid)
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => customer_response,
      }

      expect(HTTParty).to receive(:delete).with(delete_customer_url, expected_params)
        .and_return(response)
      res = Iamport.delete_customer(customer_uid)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["response"]["customer_uid"]).to be_a_kind_of(String)
    end

    it "get customer_payments" do
      customer_payments_url =
        sprintf("%s/subscribe/customers/%s/payments", IAMPORT_HOST, customer_uid)

      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => customer_payment_response,
      }

      expect(HTTParty).to receive(:get).with(customer_payments_url, expected_params)
        .and_return(response)
      res = Iamport.customer_payments(customer_uid)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["list"]).to be_a_kind_of(Array)
      expect(res["response"]["response"]["total"]).to eq(1)
      expect(res["response"]["response"]["list"].first["merchant_uid"]).to eq(MERCHANT_UID)
      expect(res["response"]["response"]["list"].first["imp_uid"]).to eq(IMP_UID)
    end

    before(:example) do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
    end
  end

  describe "cancel" do
    it "return cancel info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/cancel"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {
          imp_uid: IMP_UID,
          merchant_uid: "M00001",
        },
      }

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "IMP_UID" => IMP_UID,
          "merchant_uid" => "M00001",
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      body = expected_params[:body]

      res = Iamport.cancel(body)
      expect(res["response"]["IMP_UID"]).to eq(IMP_UID)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
    end
  end

  describe "find" do
    it "return pyments using merchant_uid" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/find/M00001"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {},
      }

      response = {
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)

      res = Iamport.find("M00001")
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["IMP_UID"]).to eq(IMP_UID)
    end
  end
end
