api_key = "xxxxxxx"
api_secret = "xxxxxx"
imp_uid = "xxxxxxx"
merchant_uid = "M00001"

describe Iamport, "::VERSION" do
  it "has a version number" do
    expect(Iamport::VERSION).not_to be nil
  end
end

describe Iamport, ".configure" do
  it "sets configuration" do
    Iamport.configure do |config|
      config.api_key = "API_KEY"
      config.api_secret = "API_SECRET"
    end
    expect(Iamport.config.api_key).to eq("API_KEY")
    expect(Iamport.config.api_secret).to eq("API_SECRET")
  end
end

describe Iamport do
  IAMPORT_HOST = "https://api.iamport.kr".freeze

  before do
    Iamport.configure do |config|
      config.api_key = api_key
      config.api_secret = api_secret
    end
  end

  describe ".token" do
    it "generates and returns new token" do
      expected_url = "#{IAMPORT_HOST}/users/getToken"
      expected_params = {
        body: {
          imp_key: api_key,
          imp_secret: api_secret,
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

    it "raises error when invalid request" do
      expect { Iamport.token }.to raise_error
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
      "imp_uid" => imp_uid,
      "merchant_uid" => merchant_uid,
      "name" => "제품이름",
      "paid_at" => 1_446_691_529,
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
      "response" => payment_json,
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
      "response" => payment_json,
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
          payment_json,
        ],
      },
    }
  end

  let(:customer_payment_info) do
    {
      merchant_uid: "xxxxx",
      amount: 11_111,
      card_number: "dddd-dddd-dddd-ddddd",
      expiry: "yyy-mm",
      birth: "dddddd",
    }
  end

  describe ".payment" do
    it "returns payment info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}"
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

      res = Iamport.payment(imp_uid)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".payments" do
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

  describe ".onetime_payments" do
    it "creates onetime payments for customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      one_time_url = "#{IAMPORT_HOST}/subscribe/payments/onetime"

      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: customer_payment_info,
      }

      response = {
        "response" => one_time_response,
      }

      expect(HTTParty).to receive(:post).with(one_time_url, expected_params).and_return(response)
      body = expected_params[:body]
      res = Iamport.onetime_payments(body)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".again_payments" do
    it "returns try again payment for customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
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
      res = Iamport.again_payments(body)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["merchant_uid"]).to eq(merchant_uid)
    end
  end

  describe ".create_customer" do
    it "creates new subscribe customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      customer_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"

      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: customer_payment_info,
      }

      response = {
        "response" => customer_response,
      }

      expect(HTTParty).to receive(:post).with(customer_url, expected_params)
        .and_return(response)

      body = expected_params[:body]
      res = Iamport.create_customer(customer_uid, body)

      expect(res["response"]["code"]).to eq(0)
      expect(res["response"]["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["response"]["customer_uid"]).to be_a_kind_of(String)
    end
  end

  describe ".get_customer" do
    it "returns subscribe customer info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      customer_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"
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
  end

  describe ".delete_customer" do
    it "returns delete customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      delete_customer_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"
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
  end

  describe ".customer_payments" do
    it "returns payments of customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      customer_payments_url =
        "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}/payments"

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
      expect(res["response"]["response"]["list"].first["merchant_uid"]).to eq(merchant_uid)
      expect(res["response"]["response"]["list"].first["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".cancel" do
    it "returns cancel info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/cancel"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN",
        },
        body: {
          imp_uid: imp_uid,
          merchant_uid: "M00001",
        },
      }

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
          "merchant_uid" => "M00001",
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)
      body = expected_params[:body]

      res = Iamport.cancel(body)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
    end
  end

  describe ".find" do
    it "returns payments using merchant_uid" do
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
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end
end
