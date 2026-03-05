# Iamport

> **⚠️ DEPRECATED**: 이 레포지토리는 2026년 3월 4일부로 deprecated 되었으며, 공식 지원이 되지 않습니다.
> 본 클라이언트는 함께 포함된 [openapi.json](./openapi.json) Swagger spec 기준으로 동작합니다.
> 추가/수정이 필요한 경우 본 레포지토리를 fork하여 수정하거나,
> [PortOne V1 REST API 문서](https://developers.portone.io/api/rest-v1?v=v1)를 참고하여 REST client를 직접 구현해주세요.

Ruby 사용자를 위한 아임포트 REST API 연동 모듈입니다.

## Code Status

[![Build Status](https://travis-ci.org/iamport/iamport-rest-client-ruby.svg?branch=master)](https://travis-ci.org/iamport/iamport-rest-client-ruby)

# 세팅하는 방법

```ruby
Iamport.configure do |config|
  config.api_key = "API_KEY"
  config.api_secret = "API_SECRET"
end
```

# API 목록

## Authentication

```ruby
Iamport.token
```

## Payments (결제)

```ruby
# 결제내역 단건조회 (imp_uid)
Iamport.payment("IMP_UID")

# 결제내역 복수조회 (imp_uid[])
Iamport.payments_by_imp_uid(["IMP_UID_1", "IMP_UID_2"])

# 결제내역 목록조회 (상태별)
Iamport.payments
Iamport.payments(status: "paid")
Iamport.payments(status: "paid", page: 2)

# 결제 단건조회 (merchant_uid)
Iamport.find("M00001")
Iamport.find("M00001", "paid")

# 결제 복수조회 (merchant_uid, 중복 포함)
Iamport.find_all("M00001")
Iamport.find_all("M00001", "paid")

# 결제 상세내역 조회
Iamport.payment_balance("IMP_UID")

# 결제금액 사전등록
Iamport.prepare(merchant_uid: "M00001", amount: 10000)

# 결제금액 사전등록 수정
Iamport.update_prepare(merchant_uid: "M00001", amount: 20000)

# 사전등록된 결제정보 조회
Iamport.prepared("M00001")

# 결제취소
Iamport.cancel(imp_uid: "IMP_UID", merchant_uid: "M00001", amount: 10000)
```

## Certifications (본인인증)

```ruby
# 본인인증 결과 조회
Iamport.get_certificate("IMP_UID")

# 본인인증 결과 삭제
Iamport.delete_certificate("IMP_UID")

# 본인인증 OTP 요청
Iamport.request_otp(name: "홍길동", phone: "01012345678", birth: "19800101")

# 본인인증 OTP 확인
Iamport.confirm_otp("IMP_UID", otp: "123456")
```

## Escrows (에스크로)

```ruby
# 배송정보 조회
Iamport.get_escrow_logis("IMP_UID")

# 배송정보 등록
Iamport.create_escrow_logis("IMP_UID", company: "CJ대한통운", invoice: "1234567890", sent_at: 1600000000)

# 배송정보 수정
Iamport.update_escrow_logis("IMP_UID", company: "CJ대한통운", invoice: "9999999999")
```

## Subscribe - Customers (정기결제 빌링키)

```ruby
# 빌링키 정보 복수조회
Iamport.customers(["CUST_UID_1", "CUST_UID_2"])

# 빌링키 발급/변경
Iamport.create_customer("CUSTOMER_UID", card_number: "1234-1234-1234-1234", expiry: "2025-12", birth: "801234")

# 빌링키 정보 조회
Iamport.customer("CUSTOMER_UID")

# 빌링키 삭제
Iamport.delete_customer("CUSTOMER_UID")

# 빌링키별 결제내역 조회
Iamport.customer_payments("CUSTOMER_UID")

# 빌링키별 결제예약 조회
Iamport.customer_schedules("CUSTOMER_UID")
```

## Subscribe - Payments (정기결제)

```ruby
# 비인증 일회성 결제
Iamport.create_onetime_payment(merchant_uid: "M00001", amount: 10000, card_number: "1234-1234-1234-1234", expiry: "2025-12", birth: "801234")

# 빌링키로 재결제
Iamport.create_payment_again(customer_uid: "CUST_UID", merchant_uid: "M00001", amount: 10000, name: "상품명")

# 결제 예약
Iamport.schedule_payments(customer_uid: "CUST_UID", schedules: [{ merchant_uid: "M00002", schedule_at: 1600000000, amount: 1000 }])

# 결제 예약 취소
Iamport.unschedule_payments(customer_uid: "CUST_UID", merchant_uid: ["M00002"])

# 결제예약 조회 (merchant_uid)
Iamport.schedule_merchant_uid("M00001")

# 결제예약 수정 (merchant_uid)
Iamport.update_schedule("M00001", schedule_at: 1700000000)

# 결제 실패 재시도
Iamport.retry_schedule("M00001")

# 결제 실패 재예약
Iamport.reschedule("M00001", schedule_at: 1700000000)

# 결제예약 조회 (customer_uid)
Iamport.schedule_customer_uid(customer_uid: "CUST_UID", from: 1500000000, to: 1700000000)

# 결제예약 복수조회 (기간)
Iamport.schedules(from: 1500000000, to: 1700000000)
```

## VBanks (가상계좌)

```ruby
# 가상계좌 발급
Iamport.create_vbank(merchant_uid: "M00001", amount: 10000, vbank_code: "004", vbank_due: 1600000000)

# 가상계좌 수정
Iamport.update_vbank("IMP_UID", amount: 20000)

# 가상계좌 삭제
Iamport.delete_vbank("IMP_UID")

# 예금주 조회
Iamport.check_holder(bank_code: "004", bank_num: "12345678")
```

## Receipts (현금영수증)

```ruby
# 현금영수증 조회
Iamport.get_receipt("IMP_UID")

# 현금영수증 발급
Iamport.create_receipt("IMP_UID", identifier: "01012345678", type: "person")

# 현금영수증 삭제
Iamport.delete_receipt("IMP_UID")

# 외부 현금영수증 조회
Iamport.get_external_receipt("M00001")

# 외부 현금영수증 발급
Iamport.create_external_receipt("M00001", identifier: "01012345678", type: "person", amount: 10000)

# 외부 현금영수증 삭제
Iamport.delete_external_receipt("M00001")
```

## Codes (은행/카드사 코드)

```ruby
# 은행코드 전체조회
Iamport.bank_codes

# 은행명 단건조회
Iamport.bank_code("004")

# 카드사코드 전체조회
Iamport.card_codes

# 카드사명 단건조회
Iamport.card_code("361")
```

## Benepia (베네피아)

```ruby
# 베네피아 포인트 조회
Iamport.benepia_point(benepia_user: "user123", benepia_password: "pass123", channel_key: "ch_key")

# 베네피아 포인트 결제
Iamport.benepia_payment(benepia_user: "user123", benepia_password: "pass123", merchant_uid: "M00001", amount: 10000, name: "상품명")
```

## CVS (편의점 결제)

```ruby
# 수납번호 발급
Iamport.create_cvs(merchant_uid: "M00001", amount: 10000)

# 수납취소
Iamport.delete_cvs("IMP_UID")
```

## KCP Quick Pay

```ruby
# KCP 선불머니 결제
Iamport.kcpquick_payment(merchant_uid: "M00001", amount: 10000)

# KCP 퀵페이 구매자 정보 삭제
Iamport.delete_kcpquick_member("MEMBER_ID")
```

## Naver Pay (네이버페이)

```ruby
# 상품주문 상세 조회
Iamport.naver_product_order("PRODUCT_ORDER_ID")

# 구매평 조회
Iamport.naver_reviews

# 포트원 거래별 상품주문 조회
Iamport.naver_product_orders("IMP_UID")

# 현금영수증 발급 가용액 조회
Iamport.naver_cash_amount("IMP_UID")

# 상품발주처리
Iamport.naver_place("IMP_UID", product_order_id: ["order_1"])

# 상품주문 발송처리
Iamport.naver_ship("IMP_UID", product_order_id: ["order_1"], delivery_method: "DELIVERY")

# 교환승인 상품 재발송처리
Iamport.naver_ship_exchanged("IMP_UID", product_order_id: ["order_1"])

# 주문환불
Iamport.naver_cancel("IMP_UID", product_order_id: ["order_1"], cancel_reason: "test")

# 환불요청 승인처리
Iamport.naver_approve_cancel("IMP_UID", product_order_id: ["order_1"])

# 상품반품요청
Iamport.naver_request_return("IMP_UID", product_order_id: ["order_1"], reason: "test")

# 반품승인 처리
Iamport.naver_approve_return("IMP_UID", product_order_id: ["order_1"])

# 반품거절 처리
Iamport.naver_reject_return("IMP_UID", product_order_id: ["order_1"], reason: "test")

# 반품보류 처리
Iamport.naver_withhold_return("IMP_UID", product_order_id: ["order_1"], reason: "test")

# 반품보류 해제 처리
Iamport.naver_resolve_return("IMP_UID", product_order_id: ["order_1"])

# 교환승인 상품 수거완료처리
Iamport.naver_collect_exchanged("IMP_UID", product_order_id: ["order_1"])

# 에스크로 주문 확정
Iamport.naver_confirm("IMP_UID")

# 네이버페이 포인트 적립
Iamport.naver_point("IMP_UID", expected_deposit_amount: 100)
```

## Partners (하위 상점)

```ruby
# 영수증 내 하위 상점 거래 등록
Iamport.create_partner_receipt("IMP_UID", tier_code: "TIER001", amount: 5000)
```

## Payco (페이코)

```ruby
# 주문상태 수정
Iamport.payco_order_status("IMP_UID", status: "DELIVERY_START")
```

## Paymentwall (페이먼트월)

```ruby
# 배송등록
Iamport.paymentwall_delivery(merchant_uid: "M00001", type: "physical")
```

## Tiers (하위 상점 정보)

```ruby
# 하위 상점 정보 조회
Iamport.tier("TIER_CODE")
```

## Users (사용자)

```ruby
# PG MID 복수조회
Iamport.pg_settings
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'httparty'
gem 'iamport'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install iamport
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iamport/iamport-rest-client-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
