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
    y = YAML::load(File.open('iamport_key.yml'))
    @api_key = y['api_key']
    @api_secret = y['api_secret']

    Iamport.configure do |config|
      config.api_key = @api_key
      config.api_secret = @api_secret
    end
  end

  describe ".token" do
    it "generates and returns new token" do
      expected_url = "#{IAMPORT_HOST}/users/getToken"
      expected_params = {
        body: {
         imp_key: @api_key,
         imp_secret: @api_secret,
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
        "response" => payment_json
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

  describe '[create|find|delete]_subscribe_customer' do
    it 'must return customer subscription info [test from Iamport]' do
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
    it 'must return customer subscription info - yjchoi card info(BC카드, 우리카드)' do
      customer_uid = "your_customer_1234"
      cards = YAML::load(File.open('cards.yml'))
      card = cards['yjchoi']
      body = {
          card_number: card['card_number'],
          expiry: card['expiry'],
          birth: card['birth'],
          pwd_2digit: card['pwd_2digit'].to_s,
          customer_email: card['customer_email'],
          customer_name: card['customer_name'],
          customer_tel: card['customer_tel']
      }

      # 1. Iamport.create_subscribe_customer
      res = Iamport.create_subscribe_customer(customer_uid, body)
      expect(res["code"]).to eq(0)
      expect(res["message"]).to be_nil
      expect(res["response"]['customer_uid']).to eq(customer_uid)
      expect(res["response"]['customer_email']).to eq(body[:customer_email])
      expect(res["response"]['customer_name']).to eq(body[:customer_name])
      expect(res["response"]['customer_tel']).to eq(body[:customer_tel])

      res = Iamport.find_subscribe_customer(customer_uid)
      expect(res["code"]).to eq(0)
      expect(res["message"]).to be_nil
      expect(res["response"]['customer_uid']).to eq(customer_uid)
      expect(res["response"]['customer_email']).to eq(body[:customer_email])
      expect(res["response"]['customer_name']).to eq(body[:customer_name])
      expect(res["response"]['customer_tel']).to eq(body[:customer_tel])

      res = Iamport.delete_subscribe_customer(customer_uid)
      expect(res["code"]).to eq(0)
      expect(res["message"]).to be_nil
      expect(res["response"]['customer_uid']).to eq(customer_uid)
      expect(res["response"]['customer_email']).to eq(body[:customer_email])
      expect(res["response"]['customer_name']).to eq(body[:customer_name])
      expect(res["response"]['customer_tel']).to eq(body[:customer_tel])

      res = Iamport.delete_subscribe_customer(customer_uid)
      expect(res['code']).to eq(1)
      expect(res['message']).to match(customer_uid)
      expect(res['response']).to be_nil
    end
  end

  describe 'create_subscribe_payments_again/payments_cancel' do
    # required fields
    let(:customer_uid) { 'your_customer_1234' }
    let(:merchant_uid) { 'test' + SecureRandom.base64(8) }
    let(:amount) { 1004 }
    let(:name) { 'TEST 주문 ' + Time.now.to_s }

    before 'it creates subscribe customer' do
      cards = YAML::load(File.open('cards.yml'))
      card = cards['yjchoi']
      body = {
          card_number: card['card_number'],
          expiry: card['expiry'],
          birth: card['birth'],
          pwd_2digit: card['pwd_2digit'].to_s,
          customer_email: card['customer_email'],
          customer_name: card['customer_name'],
          customer_tel: card['customer_tel']
      }

      # 1. Iamport.create_subscribe_customer
      res = Iamport.create_subscribe_customer(customer_uid, body)
      expect(res['code']).to eq(0)
    end
    it 'must create payments and cancel it' do
      # 1. 결제 신청
      res = Iamport.create_subscribe_payments_again(customer_uid, merchant_uid, amount, name, buyer_name: 'TEST_NAME', buyer_tel: 'TEST_TEL')

      expect(res['code']).to eq(0)
      expect(res['response']['imp_uid']).not_to be_nil
      expect(res['response']['merchant_uid']).to eq(merchant_uid)
      expect(res['response']['amount']).to eq(amount)
      expect(res['response']['name']).to eq(name)
      expect(res['response']['buyer_name']).to eq('TEST_NAME')
      expect(res['response']['buyer_tel']).to eq('TEST_TEL')

      imp_uid = res['response']['imp_uid']

      # 2. 결제 조회
      res = Iamport.payment(imp_uid)
      expect(res['code']).to eq(0)
      expect(res['response']['imp_uid']).not_to be_nil
      expect(res['response']['merchant_uid']).to eq(merchant_uid)
      expect(res['response']['amount']).to eq(amount)
      expect(res['response']['name']).to eq(name)
      expect(res['response']['buyer_name']).to eq('TEST_NAME')
      expect(res['response']['buyer_tel']).to eq('TEST_TEL')

      # 2-1. payment status - 정상결제
      expect(Iamport.payment_status(imp_uid)).to eq 'paid'

      # 3. 결제 취소
      res = Iamport.cancel(imp_uid: imp_uid)
      expect(res['response']['status']).to eq('cancelled')

      # 3-1. payment status - 취소된결제
      expect(Iamport.payment_status(imp_uid)).to eq 'cancelled'

      # 4. non existing imp_uid
      expect(Iamport.payment_status('non_existing_imp_uid')).to eq '존재하지 않는 결제정보입니다.'
    end
  end
end

