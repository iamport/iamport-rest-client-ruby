$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'iamport'
require 'yaml'
require 'securerandom'

y = YAML::load(File.open('iamport_key.yml'))

RSpec.configure do |c|
  c.before(:example) do
    Iamport.config.api_key = y['api_key']
    Iamport.config.api_secret = y['api_secret']
  end
end
