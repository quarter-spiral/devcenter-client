require "devcenter-client/version"

require "service-client"

module Devcenter
  class Client
    API_VERSION = 'v1'

    attr_reader :client

    def initialize(url)
      @client = Service::Client.new(url)

      # Public Games
      @client.urls.add(:games_public, :get, "/#{API_VERSION}/public/games")

      # Platform Data Games
      @client.urls.add(:game, :get, "/#{API_VERSION}/games/:uuid:")
    end

    def list_games(uuids = nil)
      options = {}
      options[:games] = uuids if uuids
      @client.get(@client.urls.games_public(), nil, options).data['games']
    end

    def get_game(token, uuid)
      @client.get(@client.urls.game(uuid: uuid), token).data
    end
  end
end

