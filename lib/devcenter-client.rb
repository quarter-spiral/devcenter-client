require "devcenter-client/version"

require "service-client"

module Devcenter
  class Client
    API_VERSION = 'v1'

    attr_reader :client

    def initialize(url)
      @client = Service::Client.new(url)

      # Games
      @client.urls.add(:games, :get,    "/#{API_VERSION}/public/games")
    end

    def list_games(uuids = nil)
      options = {}
      options[:games] = uuids if uuids
      @client.get(@client.urls.games(), nil, options).data['games']
    end
  end
end

