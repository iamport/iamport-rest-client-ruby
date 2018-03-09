$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "iamport"
require "pry"

RSpec.configure do |c|
  c.before(:example) do
    Iamport.config.api_key = nil
    Iamport.config.api_secret = nil
  end
end
