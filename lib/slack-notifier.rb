require 'net/http'
require 'uri'
require 'json'

require_relative 'slack-notifier/link_formatter'

module Slack
  class Notifier

    # these act as defaults
    # if they are set
    attr_accessor :channel, :username

    attr_reader :team, :token

    def initialize team, token
      @team  = team
      @token = token
    end

    def ping message, options={}
      message = LinkFormatter.format(message)
      payload = { text: message }.merge(default_payload).merge(options)

      unless payload.has_key? :channel
        raise ArgumentError, "You must set a channel"
      end
      
      req = Net::HTTP::Post.new(endpoint.request_uri)
      req.set_form_data(payload: payload.to_json)

      response = Net::HTTP.start(endpoint.host, endpoint.port, :use_ssl => true)  do |http|
        res = http.request(req)
        if res.body == "ok"
          return true 
        else
          return res.body
        end
      end

      response
    end

    private

      def default_payload
        payload = {}
        payload[:channel]  = channel  if channel
        payload[:username] = username if username
        payload
      end

      def endpoint
        URI.parse "https://#{team}.slack.com/services/hooks/incoming-webhook?token=#{token}"
      end

  end
end