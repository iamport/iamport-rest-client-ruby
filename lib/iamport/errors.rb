module Iamport
  class Error < StandardError
    attr_reader :status_code
    attr_reader :header
    attr_reader :body

    def initialize(err, status_code: nil, header: nil, body: nil)
      @cause = nil

      if err.respond_to?(:backtrace)
        super(err.message)
        @cause = err
      else
        super(err.to_s)
      end
      @status_code = status_code
      @header = header.dup unless header.nil?
      @body = body
    end

    def backtrace
      if @cause
        @cause.backtrace
      else
        super
      end
    end
  end

  # A 401 HTTP error occurred.
  class AuthorizationError < Error
  end
end
