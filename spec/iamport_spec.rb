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
      expect { Iamport.token }.to raise_error("Invalid Token")
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

  let(:customer_payment_info) do
    {
      merchant_uid: "xxxxx",
      amount: 11_111,
      card_number: "dddd-dddd-dddd-ddddd",
      expiry: "yyy-mm",
      birth: "dddddd",
    }
  end

  let(:token_headers) do
    {
      headers: {
        "Authorization" => "NEW_TOKEN",
      },
    }
  end

  let(:get_params) do
    {
      headers: {
        "Authorization" => "NEW_TOKEN",
      },
      body: {},
    }
  end

  let(:json_headers) do
    {
      headers: {
        "Authorization" => "NEW_TOKEN",
        "Content-Type" => "application/json",
      },
    }
  end

  let(:success_response) do
    {
      "code" => 0,
      "message" => "",
      "response" => {},
    }
  end

  # ============================================================
  # Payments
  # ============================================================

  describe ".payment" do
    it "returns payment info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}"

      response = {
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.payment(imp_uid)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".payments_by_imp_uid" do
    it "returns multiple payments by imp_uid list" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      uid1 = "imp_uid_1"
      uid2 = "imp_uid_2"
      expected_url = "#{IAMPORT_HOST}/payments?imp_uid[]=#{uid1}&imp_uid[]=#{uid2}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [payment_json, payment_json],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.payments_by_imp_uid([uid1, uid2])
      expect(res["response"].size).to eq(2)
    end
  end

  describe ".payments" do
    it "returns payment list" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/status/all?page=1"

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

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)
      res = Iamport.payments
      expect(res["response"]["total"]).to eq(150)
      expect(res["response"]["list"].size).to eq(2)
    end
  end

  describe ".find" do
    it "returns payments using merchant_uid" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      expected_url = "#{IAMPORT_HOST}/payments/find/M00001"

      response = {
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.find("M00001")
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end

    it "returns payments using merchant_uid with payment_status" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      expected_url = "#{IAMPORT_HOST}/payments/find/M00001/paid"

      response = {
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.find("M00001", "paid")
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".find_all" do
    it "returns all payments using merchant_uid" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      expected_url = "#{IAMPORT_HOST}/payments/findAll/M00001"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [payment_json],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.find_all("M00001")
      expect(res["response"].size).to eq(1)
    end

    it "returns all payments using merchant_uid with payment_status" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      expected_url = "#{IAMPORT_HOST}/payments/findAll/M00001/paid"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [payment_json],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.find_all("M00001", "paid")
      expect(res["response"].size).to eq(1)
    end
  end

  describe ".payment_balance" do
    it "returns payment balance detail" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/balance"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "amount" => 10_000,
          "cash_receipt" => {},
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.payment_balance(imp_uid)
      expect(res["code"]).to eq(0)
      expect(res["response"]["amount"]).to eq(10_000)
    end
  end

  describe ".prepare" do
    it "returns prepared info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/prepare"
      body = {
        "merchant_uid" => "M00001",
        "amount" => 10000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
          "amount" => 10000,
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.prepare(body)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["amount"]).to eq(10000)
    end
  end

  describe ".update_prepare" do
    it "updates prepared payment info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/prepare"
      body = {
        "merchant_uid" => "M00001",
        "amount" => 20000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
          "amount" => 20000,
        },
      }

      expect(HTTParty).to receive(:put).with(expected_url, expected_params).and_return(response)

      res = Iamport.update_prepare(body)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["amount"]).to eq(20000)
    end
  end

  describe ".prepared" do
    it "returns prepared info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/prepare/M00001"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
          "amount" => 10000,
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.prepared("M00001")
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["amount"]).to eq(10000)
    end
  end

  describe ".cancel" do
    it "returns cancel info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/payments/cancel"
      body = {
        imp_uid: imp_uid,
        merchant_uid: "M00001",
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
          "merchant_uid" => "M00001",
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.cancel(body)

      expect(res["response"]["imp_uid"]).to eq(imp_uid)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
    end
  end

  # ============================================================
  # Certifications
  # ============================================================

  describe ".get_certificate" do
    it "returns certificate info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/certifications/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
          "name" => "홍길동",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.get_certificate(imp_uid)
      expect(res["code"]).to eq(0)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".delete_certificate" do
    it "deletes certificate" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/certifications/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
      }

      expect(HTTParty).to receive(:delete).with(expected_url, get_params).and_return(response)

      res = Iamport.delete_certificate(imp_uid)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".request_otp" do
    it "requests OTP for identity verification" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/certifications/otp/request"
      body = {
        name: "홍길동",
        phone: "01012345678",
        birth: "19800101",
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.request_otp(body)
      expect(res["code"]).to eq(0)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".confirm_otp" do
    it "confirms OTP for identity verification" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/certifications/otp/confirm/#{imp_uid}"
      body = { otp: "123456" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
          "certified" => true,
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.confirm_otp(imp_uid, body)
      expect(res["code"]).to eq(0)
      expect(res["response"]["certified"]).to eq(true)
    end
  end

  # ============================================================
  # Escrows
  # ============================================================

  describe ".get_escrow_logis" do
    it "returns escrow logistics info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/escrows/logis/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "company" => "CJ대한통운",
          "invoice" => "1234567890",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.get_escrow_logis(imp_uid)
      expect(res["code"]).to eq(0)
      expect(res["response"]["company"]).to eq("CJ대한통운")
    end
  end

  describe ".create_escrow_logis" do
    it "creates escrow logistics info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/escrows/logis/#{imp_uid}"
      body = {
        company: "CJ대한통운",
        invoice: "1234567890",
        sent_at: 1_600_000_000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.create_escrow_logis(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".update_escrow_logis" do
    it "updates escrow logistics info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/escrows/logis/#{imp_uid}"
      body = {
        company: "CJ대한통운",
        invoice: "9999999999",
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:put).with(expected_url, expected_params).and_return(response)

      res = Iamport.update_escrow_logis(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Subscribe - Customers
  # ============================================================

  describe ".customers" do
    it "returns multiple customer billing key info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      uid1 = "cust_1"
      uid2 = "cust_2"
      expected_url = "#{IAMPORT_HOST}/subscribe/customers?customer_uid[]=#{uid1}&customer_uid[]=#{uid2}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [customer_response["response"]],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.customers([uid1, uid2])
      expect(res["code"]).to eq(0)
    end
  end

  describe ".create_customer" do
    it "creates new subscriber" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      customer_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"

      expected_params = json_headers.merge(body: customer_payment_info.to_json)

      expect(HTTParty).to receive(:post).with(customer_url, expected_params)
        .and_return(customer_response)

      body = customer_payment_info
      res = Iamport.create_customer(customer_uid, body)

      expect(res["code"]).to eq(0)
      expect(res["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["customer_uid"]).to be_a_kind_of(String)
    end
  end

  describe ".customer" do
    it "returns subscribe customer info" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      customer_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"

      expect(HTTParty).to receive(:get).with(customer_url, get_params)
        .and_return(customer_response)

      res = Iamport.customer(customer_uid)

      expect(res["code"]).to eq(0)
      expect(res["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["customer_uid"]).to be_a_kind_of(String)
    end
  end

  describe ".delete_customer" do
    it "deletes customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      delete_customer_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"

      expect(HTTParty).to receive(:delete).with(delete_customer_url, get_params)
        .and_return(customer_response)
      res = Iamport.delete_customer(customer_uid)

      expect(res["code"]).to eq(0)
      expect(res["response"]["customer_uid"]).to eq(customer_uid)
      expect(res["response"]["customer_uid"]).to be_a_kind_of(String)
    end
  end

  describe ".customer_payments" do
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

    it "returns payments of customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      customer_payments_url =
        "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}/payments"

      expect(HTTParty).to receive(:get).with(customer_payments_url, get_params)
        .and_return(customer_payment_response)
      res = Iamport.customer_payments(customer_uid)

      expect(res["code"]).to eq(0)
      expect(res["response"]["list"]).to be_a_kind_of(Array)
      expect(res["response"]["total"]).to eq(1)
      expect(res["response"]["list"].first["merchant_uid"]).to eq(merchant_uid)
      expect(res["response"]["list"].first["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".customer_schedules" do
    it "returns schedules of customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}/schedules"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "total" => 1,
          "list" => [
            { "merchant_uid" => merchant_uid, "schedule_at" => 1_600_000_000 },
          ],
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.customer_schedules(customer_uid)
      expect(res["code"]).to eq(0)
      expect(res["response"]["total"]).to eq(1)
    end
  end

  # ============================================================
  # Subscribe - Payments
  # ============================================================

  describe ".create_onetime_payment" do
    let(:one_time_response) do
      {
        "code" => 0,
        "message" => "string",
        "response" => payment_json,
      }
    end

    it "creates an onetime payment" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      one_time_url = "#{IAMPORT_HOST}/subscribe/payments/onetime"

      expected_params = json_headers.merge(body: customer_payment_info.to_json)

      expect(HTTParty).to receive(:post).with(one_time_url, expected_params)
        .and_return(one_time_response)
      res = Iamport.create_onetime_payment(customer_payment_info)

      expect(res["code"]).to eq(0)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".create_payment_again" do
    let(:payment_again_response) do
      {
        "code" => 0,
        "message" => "string",
        "response" => payment_json,
      }
    end

    it "creates payment again for customer" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"
      payment_again_url = "#{IAMPORT_HOST}/subscribe/payments/again"
      payload = {
        customer_uid: "xxxxx",
        merchant_uid: "xxxxx",
        amount: 1,
        name: "tester",
      }
      expected_params = json_headers.merge(body: payload.to_json)

      expect(HTTParty).to receive(:post).with(payment_again_url, expected_params)
        .and_return(payment_again_response)
      res = Iamport.create_payment_again(payload)

      expect(res["code"]).to eq(0)
      expect(res["response"]["merchant_uid"]).to eq(merchant_uid)
    end
  end

  describe ".schedule_payments" do
    it "schedules payments" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule"
      payload = {
        customer_uid: "cust_1",
        schedules: [
          { merchant_uid: "M00002", schedule_at: 1_600_000_000, amount: 1000 },
        ],
      }
      expected_params = json_headers.merge(body: payload.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [
          { "merchant_uid" => "M00002", "schedule_at" => 1_600_000_000 },
        ],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.schedule_payments(payload)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".unschedule_payments" do
    it "unschedules payments" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/payments/unschedule"
      payload = {
        customer_uid: "cust_1",
        merchant_uid: ["M00002"],
      }
      expected_params = json_headers.merge(body: payload.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [
          { "merchant_uid" => "M00002" },
        ],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.unschedule_payments(payload)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".schedule_merchant_uid" do
    it "returns schedule by merchant_uid" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule/M00001"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.schedule_merchant_uid("M00001")
      expect(res["code"]).to eq(0)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
    end
  end

  describe ".update_schedule" do
    it "updates schedule by merchant_uid" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule/M00001"
      body = { schedule_at: 1_700_000_000 }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
          "schedule_at" => 1_700_000_000,
        },
      }

      expect(HTTParty).to receive(:put).with(expected_url, expected_params).and_return(response)

      res = Iamport.update_schedule("M00001", body)
      expect(res["code"]).to eq(0)
      expect(res["response"]["schedule_at"]).to eq(1_700_000_000)
    end
  end

  describe ".retry_schedule" do
    it "retries failed scheduled payment" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule/M00001/retry"
      body = {}
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.retry_schedule("M00001")
      expect(res["code"]).to eq(0)
    end
  end

  describe ".reschedule" do
    it "reschedules failed payment" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule/M00001/reschedule"
      body = { schedule_at: 1_700_000_000 }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
          "schedule_at" => 1_700_000_000,
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.reschedule("M00001", body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".schedule_customer_uid" do
    it "returns schedules by customer_uid" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      from_time = 1_500_000_000
      to_time = 1_700_000_000
      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule/customers/#{customer_uid}?from=#{from_time}&to=#{to_time}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "total" => 1,
          "list" => [],
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.schedule_customer_uid(customer_uid: customer_uid, from: from_time, to: to_time)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".schedules" do
    it "returns all schedules by date range" do
      allow(Iamport).to receive(:token).and_return "NEW_TOKEN"

      from_time = 1_500_000_000
      to_time = 1_700_000_000
      expected_url = "#{IAMPORT_HOST}/subscribe/payments/schedule?from=#{from_time}&to=#{to_time}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "total" => 0,
          "list" => [],
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.schedules(from: from_time, to: to_time)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Virtual Banks
  # ============================================================

  describe ".create_vbank" do
    it "creates virtual bank" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/vbanks"
      body = {
        merchant_uid: "M00001",
        amount: 10000,
        vbank_code: "004",
        vbank_due: 1_600_000_000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.create_vbank(body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".update_vbank" do
    it "updates virtual bank" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/vbanks/#{imp_uid}"
      body = { amount: 20000 }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:put).with(expected_url, expected_params).and_return(response)

      res = Iamport.update_vbank(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".delete_vbank" do
    it "deletes virtual bank" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/vbanks/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:delete).with(expected_url, get_params).and_return(response)

      res = Iamport.delete_vbank(imp_uid)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".check_holder" do
    it "returns bank account holder info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/vbanks/holder?bank_code=004&bank_num=12345678"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "bank_holder" => "홍길동",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.check_holder(bank_code: "004", bank_num: "12345678")
      expect(res["code"]).to eq(0)
      expect(res["response"]["bank_holder"]).to eq("홍길동")
    end
  end

  # ============================================================
  # Receipts
  # ============================================================

  describe ".get_receipt" do
    it "returns receipt info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/receipts/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
          "receipt_tid" => "R0001",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.get_receipt(imp_uid)
      expect(res["code"]).to eq(0)
      expect(res["response"]["imp_uid"]).to eq(imp_uid)
    end
  end

  describe ".create_receipt" do
    it "creates receipt" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/receipts/#{imp_uid}"
      body = { identifier: "01012345678", type: "person" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "imp_uid" => imp_uid,
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.create_receipt(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".delete_receipt" do
    it "deletes receipt" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/receipts/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
      }

      expect(HTTParty).to receive(:delete).with(expected_url, get_params).and_return(response)

      res = Iamport.delete_receipt(imp_uid)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".get_external_receipt" do
    it "returns external receipt info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/receipts/external/M00001"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.get_external_receipt("M00001")
      expect(res["code"]).to eq(0)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
    end
  end

  describe ".create_external_receipt" do
    it "creates external receipt" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/receipts/external/M00001"
      body = {
        identifier: "01012345678",
        type: "person",
        amount: 10000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "merchant_uid" => "M00001",
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.create_external_receipt("M00001", body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".delete_external_receipt" do
    it "deletes external receipt" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/receipts/external/M00001"

      response = {
        "code" => 0,
        "message" => "",
      }

      expect(HTTParty).to receive(:delete).with(expected_url, get_params).and_return(response)

      res = Iamport.delete_external_receipt("M00001")
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Codes (Banks & Cards)
  # ============================================================

  describe ".bank_codes" do
    it "returns all bank codes" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/banks"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [
          { "code" => "004", "name" => "국민은행" },
        ],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.bank_codes
      expect(res["code"]).to eq(0)
      expect(res["response"]).to be_a_kind_of(Array)
    end
  end

  describe ".bank_code" do
    it "returns bank name by code" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/banks/004"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "code" => "004",
          "name" => "국민은행",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.bank_code("004")
      expect(res["code"]).to eq(0)
      expect(res["response"]["name"]).to eq("국민은행")
    end
  end

  describe ".card_codes" do
    it "returns all card codes" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/cards"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [
          { "code" => "361", "name" => "BC카드" },
        ],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.card_codes
      expect(res["code"]).to eq(0)
      expect(res["response"]).to be_a_kind_of(Array)
    end
  end

  describe ".card_code" do
    it "returns card name by code" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/cards/361"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "code" => "361",
          "name" => "BC카드",
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.card_code("361")
      expect(res["code"]).to eq(0)
      expect(res["response"]["name"]).to eq("BC카드")
    end
  end

  # ============================================================
  # Benepia
  # ============================================================

  describe ".benepia_point" do
    it "queries Benepia point" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/benepia/point"
      body = {
        benepia_user: "user123",
        benepia_password: "pass123",
        channel_key: "ch_key",
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "point" => 50000,
        },
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.benepia_point(body)
      expect(res["code"]).to eq(0)
      expect(res["response"]["point"]).to eq(50000)
    end
  end

  describe ".benepia_payment" do
    it "pays with Benepia point" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/benepia/payment"
      body = {
        benepia_user: "user123",
        benepia_password: "pass123",
        merchant_uid: "M00001",
        amount: 10000,
        name: "상품명",
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.benepia_payment(body)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # CVS
  # ============================================================

  describe ".create_cvs" do
    it "issues CVS payment" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/cvs"
      body = {
        merchant_uid: "M00001",
        amount: 10000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.create_cvs(body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".delete_cvs" do
    it "revokes CVS payment" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/cvs/#{imp_uid}"

      response = {
        "code" => 0,
        "message" => "",
      }

      expect(HTTParty).to receive(:delete).with(expected_url, get_params).and_return(response)

      res = Iamport.delete_cvs(imp_uid)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # KCP Quick Pay
  # ============================================================

  describe ".kcpquick_payment" do
    it "pays with KCP quick pay money" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/kcpquick/payment/money"
      body = {
        merchant_uid: "M00001",
        amount: 10000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.kcpquick_payment(body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".delete_kcpquick_member" do
    it "deletes KCP quick pay member" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      member_id = "member_123"
      expected_url = "#{IAMPORT_HOST}/kcpquick/members/#{member_id}"

      response = {
        "code" => 0,
        "message" => "",
      }

      expect(HTTParty).to receive(:delete).with(expected_url, get_params).and_return(response)

      res = Iamport.delete_kcpquick_member(member_id)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Naver Pay
  # ============================================================

  describe ".naver_product_order" do
    it "returns single Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      product_order_id = "naver_order_1"
      expected_url = "#{IAMPORT_HOST}/naver/product-orders/#{product_order_id}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "product_order_id" => product_order_id,
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.naver_product_order(product_order_id)
      expect(res["code"]).to eq(0)
      expect(res["response"]["product_order_id"]).to eq(product_order_id)
    end
  end

  describe ".naver_reviews" do
    it "returns Naver reviews" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/naver/reviews"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.naver_reviews
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_product_orders" do
    it "returns Naver product orders by imp_uid" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/product-orders"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.naver_product_orders(imp_uid)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_cash_amount" do
    it "returns Naver cash amount" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/cash-amount"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "cash_amount" => 5000,
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.naver_cash_amount(imp_uid)
      expect(res["code"]).to eq(0)
      expect(res["response"]["cash_amount"]).to eq(5000)
    end
  end

  describe ".naver_place" do
    it "places Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/place"
      body = { product_order_id: ["order_1"] }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_place(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_ship" do
    it "ships Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/ship"
      body = { product_order_id: ["order_1"], delivery_method: "DELIVERY" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_ship(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_ship_exchanged" do
    it "ships exchanged Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/ship-exchanged"
      body = { product_order_id: ["order_1"] }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_ship_exchanged(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_cancel" do
    it "cancels Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/cancel"
      body = { product_order_id: ["order_1"], cancel_reason: "test" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_cancel(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_approve_cancel" do
    it "approves cancel for Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/approve-cancel"
      body = { product_order_id: ["order_1"] }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_approve_cancel(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_request_return" do
    it "requests return for Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/request-return"
      body = { product_order_id: ["order_1"], reason: "test" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_request_return(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_approve_return" do
    it "approves return for Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/approve-return"
      body = { product_order_id: ["order_1"] }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_approve_return(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_reject_return" do
    it "rejects return for Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/reject-return"
      body = { product_order_id: ["order_1"], reason: "test" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_reject_return(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_withhold_return" do
    it "withholds return for Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/withhold-return"
      body = { product_order_id: ["order_1"], reason: "test" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_withhold_return(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_resolve_return" do
    it "resolves return for Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/resolve-return"
      body = { product_order_id: ["order_1"] }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_resolve_return(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_collect_exchanged" do
    it "collects exchanged Naver product order" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/collect-exchanged"
      body = { product_order_id: ["order_1"] }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_collect_exchanged(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_confirm" do
    it "confirms Naver payment (escrow)" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/confirm"
      body = {}
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_confirm(imp_uid)
      expect(res["code"]).to eq(0)
    end
  end

  describe ".naver_point" do
    it "deposits Naver point" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/#{imp_uid}/naver/point"
      body = { expected_deposit_amount: 100 }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.naver_point(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Partners
  # ============================================================

  describe ".create_partner_receipt" do
    it "creates partner receipt" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/partners/receipts/#{imp_uid}"
      body = {
        tier_code: "TIER001",
        amount: 5000,
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.create_partner_receipt(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Payco
  # ============================================================

  describe ".payco_order_status" do
    it "changes Payco order status" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payco/orders/status/#{imp_uid}"
      body = { status: "DELIVERY_START" }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.payco_order_status(imp_uid, body)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Paymentwall
  # ============================================================

  describe ".paymentwall_delivery" do
    it "registers Paymentwall delivery" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/paymentwall/delivery"
      body = {
        merchant_uid: "M00001",
        type: "physical",
      }
      expected_params = json_headers.merge(body: body.to_json)

      response = {
        "code" => 0,
        "message" => "",
        "response" => {},
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      res = Iamport.paymentwall_delivery(body)
      expect(res["code"]).to eq(0)
    end
  end

  # ============================================================
  # Tiers
  # ============================================================

  describe ".tier" do
    it "returns tier info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      tier_code = "TIER001"
      expected_url = "#{IAMPORT_HOST}/tiers/#{tier_code}"

      response = {
        "code" => 0,
        "message" => "",
        "response" => {
          "tier_code" => tier_code,
        },
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.tier(tier_code)
      expect(res["code"]).to eq(0)
      expect(res["response"]["tier_code"]).to eq(tier_code)
    end
  end

  # ============================================================
  # Users
  # ============================================================

  describe ".pg_settings" do
    it "returns PG setting list" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/users/pg"

      response = {
        "code" => 0,
        "message" => "",
        "response" => [],
      }

      expect(HTTParty).to receive(:get).with(expected_url, get_params).and_return(response)

      res = Iamport.pg_settings
      expect(res["code"]).to eq(0)
    end
  end
end
