# Iamport

Ruby 사용자를 위한 아임포트 REST API 연동 모듈입니다.

# 세팅하는 방법
```
Iamport.configure do |config|
  config.api_key = "API_KEY"
  config.api_secret = "API_SECRET"
end
```

# 사용법
## token API
```
Iamport.token
```

## payment API
```
Iamport.payment("IMP_UID")
```

## payments API
```
Iamport.payments
Iamport.payments(status: "paid")
Iamport.payments(status: "paid", page: 2)
```

## cancel API
body의 값은 [API 문서 - cancel](https://api.iamport.kr/#!/payments/cancelPayment)에 있는 사용하는 것을 추가하여 진행하면 됩니다.​
```
body = {
  imp_uid: "IMP_UID",
  merchant_uid: "M00001",
  amount: ""
}
Iamport.cancel(body)
```

## find API
가맹점지정 고유번호를 이용하여 결제정보를 찾는 API

```
Iamport.find("M00001")
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iamport', github: 'iamport/iamport-rest-client-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iamport

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/iamport. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

