# frozen_string_literal: true

module Telebugs
  # Responsible for sending HTTP requests to Telebugs.
  class Sender
    CONTENT_TYPE = "application/json"

    USER_AGENT = "telebugs-ruby/#{Telebugs::VERSION} (#{RUBY_ENGINE}/#{RUBY_VERSION})"

    def initialize
      @config = Config.instance
      @authorization = "Bearer #{@config.api_key}"
    end

    def send(data)
      req = build_request(@config.api_url, data)

      resp = build_https(@config.api_url).request(req)
      if resp.code_type == Net::HTTPCreated
        return JSON.parse(resp.body)
      end

      raise HTTPError, "#{resp.code_type} (#{resp.code}): #{JSON.parse(resp.body)}"
    end

    private

    def build_request(uri, data)
      Net::HTTP::Post.new(uri.request_uri).tap do |req|
        req["Authorization"] = @authorization
        req["Content-Type"] = CONTENT_TYPE
        req["User-Agent"] = USER_AGENT

        req.body = data.to_json
      end
    end

    def build_https(uri)
      Net::HTTP.new(uri.host, uri.port).tap do |https|
        https.use_ssl = uri.is_a?(URI::HTTPS)
      end
    end
  end
end
