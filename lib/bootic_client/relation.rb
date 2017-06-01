require "bootic_client/whiny_uri"
require "bootic_client/entity"

module BooticClient

  class Relation

    GET = 'get'.freeze
    HEAD = 'head'.freeze
    OPTIONS = 'options'.freeze

    def initialize(attrs, client, wrapper_class = Entity)
      @attrs, @client, @wrapper_class = attrs, client, wrapper_class
    end

    def inspect
      %(#<#{self.class.name} #{attrs.inspect}>)
    end

    def href
      attrs['href']
    end

    def templated?
      !!attrs['templated']
    end

    def parameters
      @parameters ||= templated? ? uri.variables : []
    end

    def name
      attrs['name']
    end

    def title
      attrs['title']
    end

    def type
      attrs['type']
    end

    def docs
      attrs['docs']
    end

    def to_hash
      attrs
    end

    def transport_method
      @transport_method ||= attrs.key?('method') ? attrs['method'].to_s.downcase : GET
    end

    def run(opts = {})
      if templated?
        uri_vars = uri.variables
        payload = opts.each_with_object({}) do |(k,v),memo|
          memo[k] = v unless uri_vars.include?(k.to_s)
        end
        # remove payload vars from URI opts if destructive action
        opts = opts.reject{|k, v| !uri_vars.include?(k.to_s) } if destructive?
        client.request_and_wrap transport_method.to_sym, uri.expand(opts), wrapper_class, payload
      else
        client.request_and_wrap transport_method.to_sym, href, wrapper_class, opts
      end
    end

    def self.expand(href, opts = {})
      WhinyURI.new(href).expand(opts)
    end

    protected
    attr_reader :wrapper_class, :client, :attrs

    def uri
      @uri ||= WhinyURI.new(href)
    end

    def destructive?
      ![GET, OPTIONS, HEAD].include? transport_method
    end
  end
end
