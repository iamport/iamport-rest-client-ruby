require 'spec_helper'
require 'httparty'

describe Iamport, "::VERSION" do
  it 'has a version number' do
    expect(Iamport::VERSION).not_to be nil
  end
end

describe Iamport, ".configure" do
  it 'sets configuration' do
    Iamport.configure do |config|
      config.api_key = "API_KEY"
      config.api_secret = "API_SECRET"
    end
    expect(Iamport.config.api_key).to eq("API_KEY")
    expect(Iamport.config.api_secret).to eq("API_SECRET")
  end
end

describe Iamport do
  IAMPORT_HOST = "https://api.iamport.kr"

  before do
    Iamport.configure do |config|
      config.api_key = "API_KEY"
      config.api_secret = "API_SECRET"
    end
  end

  describe ".token" do
    it "generates and returns new token" do
      expected_url = "#{IAMPORT_HOST}/users/getToken"
      expected_params = {
        body: {
         imp_key: "API_KEY",
         imp_secret: "API_SECRET",
        }
      }

      response = {
        "response" => {
          "access_token" => "NEW_TOKEN"
        }
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      expect(Iamport.token).to eq("NEW_TOKEN")
    end
  end

  let(:payment_json) {
    {
      "amount" => 10000,
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
      "imp_uid" => "IMP_UID",
      "merchant_uid" => "M00001",
      "name" => "제품이름",
      "paid_at" => 1446691529,
      "pay_method" => "card",
      "pg_provider" => "nice",
      "pg_tid" => "w00000000000000000000000000001",
      "receipt_url" => "RECEIPT_URL",
      "status" => "paid",
      "user_agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 9_0_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13A452 Safari/601.1",
      "vbank_date" => 0,
      "vbank_holder" => nil,
      "vbank_name" => nil,
      "vbank_num" => nil,
    }
  }

  describe "payment" do
    it "returns payment info" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/IMP_UID"
      expected_params = {
          headers: {
              "Authorization" => "NEW_TOKEN"
          },
          body: {}
      }

      response = {
        "response" => payment_json,
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)

      res = Iamport.payment("IMP_UID")
      expect(res["response"]["imp_uid"]).to eq("IMP_UID")
    end
  end

  describe "payments" do
    it "returns payment list" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")

      expected_url = "#{IAMPORT_HOST}/payments/status/all?page=1"
      expected_params = {
          headers: {
              "Authorization" => "NEW_TOKEN"
          },
          body: {}
      }

      response = {
        "response" => {
          "total" => 150,
          "previous" => false,
          "next" => 2,
          "list" => [
            payment_json,
            payment_json,
          ]
        }
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)

      res = Iamport.payments
      expect(res["response"]["total"]).to eq(150)
      expect(res["response"]["list"].size).to eq(2)
    end
  end

  describe 'prepare' do
    it 'return prepared info' do
      allow(Iamport).to receive(:token).and_return 'NEW_TOKEN'

      expected_url = "#{IAMPORT_HOST}/payments/prepare"
      expected_params = {
          headers: {
              "Authorization" => "NEW_TOKEN"
          },
          body: {
              "merchant_uid" => "M00001",
              "amount" => 10000,
          }
      }

      response = {
          "code" => 0,
          "message" => '',
          "response" => {
              "merchant_uid" => "M00001",
              "amount" => 10000,
          }
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      body = expected_params[:body]

      res = Iamport.prepare(body)
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["amount"]).to eq(10000)
    end
  end

  describe 'prepared' do
    it 'return prepared info' do
      allow(Iamport).to receive(:token).and_return 'NEW_TOKEN'

      expected_url = "#{IAMPORT_HOST}/payments/prepare/M00001"
      expected_params = {
          headers: {
              "Authorization" => "NEW_TOKEN"
          },
          body: {}
      }

      response = {
          "code" => 0,
          "message" => '',
          "response" => {
              "merchant_uid" => "M00001",
              "amount" => 10000,
          }
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)

      res = Iamport.prepared("M00001")
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["amount"]).to eq(10000)
    end
  end

  describe 'cancel' do
    it 'return cancel info' do
      allow(Iamport).to receive(:token).and_return 'NEW_TOKEN'

      expected_url = "#{IAMPORT_HOST}/payments/cancel"
      expected_params = {
          headers: {
              "Authorization" => "NEW_TOKEN"
          },
          body: {
              imp_uid: "IMP_UID",
              merchant_uid: "M00001"
          }
      }

      response = {
          "code" => 0,
          "message" => '',
          "response" => {
              "imp_uid" => "IMP_UID",
              "merchant_uid" => "M00001"
          }
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      body = expected_params[:body]

      res = Iamport.cancel(body)
      expect(res["response"]["imp_uid"]).to eq("IMP_UID")
      expect(res["response"]["merchant_uid"]).to eq("M00001")
    end
  end

  describe 'find' do
    it 'return pyments using merchant_uid' do
      allow(Iamport).to receive(:token).and_return 'NEW_TOKEN'

      expected_url = "#{IAMPORT_HOST}/payments/find/M00001"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN"
        },
        body: {}
      }

      response = {
          "response" => payment_json
      }

      expect(HTTParty).to receive(:get).with(expected_url, expected_params).and_return(response)

      res = Iamport.find("M00001")
      expect(res["response"]["merchant_uid"]).to eq("M00001")
      expect(res["response"]["imp_uid"]).to eq("IMP_UID")
    end
  end

  describe 'create_subscribe_customer' do
    it 'must return customer subscription info' do
      allow(Iamport).to receive(:token).and_return 'NEW_TOKEN'

      customer_uid = "your_customer_1234"
      expected_url = "#{IAMPORT_HOST}/subscribe/customers/#{customer_uid}"
      expected_params = {
        headers: {
          "Authorization" => "NEW_TOKEN"
        },
        body: {
          card_number: "1234-1234-1234-1234",
          expiry: "2019-07",
          birth: "801234",
          pwd_2digit: "00",
          customer_email: "user@your_customer.com",
          customer_name: "홍길동",
          customer_tel: "010-1234-5678"
        }
      }

      response = {
        "code"=>-1,
        "message"=>"카드정보 인증 및 빌키 발급에 실패하였습니다. [F112]유효하지않은 카드번호를 입력하셨습니다. (card_bin 없음)",
        "response"=>nil
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      body = expected_params[:body]

      res = Iamport.create_subscribe_customer(customer_uid, body)
      expect(res["code"]).to eq(response["code"])
      expect(res["message"]).to eq(response["message"])
      expect(res["response"]).to eq(response["response"])
    end
  end
end

