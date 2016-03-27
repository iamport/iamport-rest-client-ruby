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
    expect(Iamport.config.api_key).to eq "API_KEY"
    expect(Iamport.config.api_secret).to eq "API_SECRET"
  end
end

describe Iamport do
  before do
    Iamport.configure do |config|
      config.api_key = "API_KEY"
      config.api_secret = "API_SECRET"
    end
  end

  describe ".token" do
    it "generates and returns new token" do
      expected_url = "https://api.iamport.kr/users/getToken"
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

      expected_url = "https://api.iamport.kr/payments/IMP_UID?_token=NEW_TOKEN"
      response = {
        "response" => payment_json,
      }
      expect(HTTParty).to receive(:post).with(expected_url).and_return(response)

      res = Iamport.payment("IMP_UID")
      expect(res["imp_uid"]).to eq("IMP_UID")
    end
  end

  describe "payments" do
    it "returns payment list" do
      allow(Iamport).to receive(:token).and_return("NEW_TOKEN")
      expected_url = "https://api.iamport.kr/payments/status/all?_token=NEW_TOKEN&page=1"
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
      expect(HTTParty).to receive(:post).with(expected_url).and_return(response)

      res = Iamport.payments
      expect(res["total"]).to eq(150)
      expect(res["list"].size).to eq(2)
    end
  end

  describe 'cancel' do
    it 'returns cancel info' do
      allow(Iamport).to receive(:token).and_return('NEW_TOKEN')

      expected_url = 'https://api.iamport.kr/payments/cancel?_token=NEW_TOKEN'
      expected_params = {
        body: {
          imp_uid: 'IMP_UID'
        }
      }
      response = {
        code: 0,
        message: '',
        response: {
          imp_id: 'IMP_UID'
        }
      }

      expect(HTTParty).to receive(:post).with(expected_url, expected_params).and_return(response)

      body = { imp_uid: 'IMP_UID' }
      res = Iamport.cancel(body)
      expect(res[:code]).to eq(0)
      expect(res[:message]).to eq('')
    end
  end
end

