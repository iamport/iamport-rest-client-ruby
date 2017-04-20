module Iamport
  module Errors
    class Error < StandardError
      attr_reader :status_code
      attr_reader :body
      def initialize(status_code: nil, body: nil)
        @status_code = status_code
        @body = body
      end
    end

    class AuthorizationError < Error
    end
  end
end
