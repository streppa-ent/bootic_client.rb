require 'faraday'
require 'faraday_middleware'

module BooticClient

  class Client

    API_URL = 'https://api.bootic.net'.freeze
    USER_AGENT = "[BooticClient v#{VERSION}] Ruby-#{RUBY_VERSION} - #{RUBY_PLATFORM}".freeze

    attr_reader :options, :last_response

    def initialize(options = {})
      @options = {
        api_url: API_URL,
        access_token: nil,
        logging: false
      }.merge(options.dup)
    end

    def get_and_wrap(href, wrapper_class)
      wrapper_class.new get(href).body, self
    end

    def get(href)
      @last_response = conn.get do |req|
        req.url href
        req.headers['Authorization'] = "Bearer #{options[:access_token]}"
        req.headers['User-Agent'] = USER_AGENT
      end

      @last_response
    end

    protected

    def conn
      @conn ||= Faraday.new(url: options[:api_url]) do |f|
        # f.use :http_cache, shared_cache: false, store: Rails.cache, logger: Rails.logger
        f.response :logger if options[:logging]
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

  end

end